from core.utils1.config import cfg  # isort: split

import os
import time

from tensorboardX import SummaryWriter
from tqdm import tqdm
import wandb

from core.utils1.datasets import create_dataloader
from core.utils1.earlystop import EarlyStopping
from core.utils1.eval import get_val_cfg, validate
from core.utils1.trainer import Trainer
from core.utils1.utils import Logger

import ssl
ssl._create_default_https_context = ssl._create_unverified_context


if __name__ == "__main__":
    print("=" * 60)
    print("AIGVDet Training")
    print("=" * 60)
    
    print("\nInitializing...")
    val_cfg = get_val_cfg(cfg, split="val", copy=True)
    cfg.dataset_root = os.path.join(cfg.dataset_root, "train")
    
    print("Loading training data...")
    data_loader = create_dataloader(cfg)
    dataset_size = len(data_loader)
    print(f"✓ Loaded {dataset_size * cfg.batch_size} training images")

    log = Logger()
    log.open(cfg.logs_path, mode="a")
    log.write("Num of training images = %d\n" % (dataset_size * cfg.batch_size))
    log.write("Config:\n" + str(cfg.to_dict()) + "\n")

    print("Setting up TensorBoard...")
    train_writer = SummaryWriter(os.path.join(cfg.exp_dir, "train"))
    val_writer = SummaryWriter(os.path.join(cfg.exp_dir, "val"))
    print(f"✓ Logs will be saved to: {cfg.exp_dir}")

    # Initialize wandb
    print("\nInitializing wandb...")
    wandb.init(
        project="aigvdet-training",
        name=cfg.exp_name,
        config=cfg.to_dict(),
        dir=cfg.exp_dir,
        resume="allow" if cfg.continue_train else None
    )
    print(f"✓ wandb tracking enabled: {wandb.run.url}")

    print("\nInitializing model...")
    trainer = Trainer(cfg)
    early_stopping = EarlyStopping(patience=cfg.earlystop_epoch, delta=-0.001, verbose=True)
    print(f"✓ Model ready (Architecture: {cfg.arch})")
    
    print("\n" + "=" * 60)
    print(f"Starting training for {cfg.nepoch} epochs")
    print("=" * 60 + "\n")
    
    for epoch in range(cfg.nepoch):
        print(f"\n{'='*60}")
        print(f"Epoch {epoch+1}/{cfg.nepoch}")
        print(f"{'='*60}")
        epoch_start_time = time.time()
        iter_data_time = time.time()
        epoch_iter = 0

        for data in tqdm(data_loader, desc=f"Training Epoch {epoch+1}", unit="batch"):
            trainer.total_steps += 1
            epoch_iter += cfg.batch_size

            trainer.set_input(data)
            trainer.optimize_parameters()

            # if trainer.total_steps % cfg.loss_freq == 0:
            #     log.write(f"Train loss: {trainer.loss} at step: {trainer.total_steps}\n")
            train_writer.add_scalar("loss", trainer.loss, trainer.total_steps)
            wandb.log({"train/loss": trainer.loss, "train/step": trainer.total_steps})

            if trainer.total_steps % cfg.save_latest_freq == 0:
                print(f"💾 Saving checkpoint (epoch {epoch+1}, step {trainer.total_steps})")
                log.write(
                    "saving the latest model %s (epoch %d, model.total_steps %d)\n"
                    % (cfg.exp_name, epoch, trainer.total_steps)
                )
                trainer.save_networks("latest")

        if epoch % cfg.save_epoch_freq == 0:
            print(f"💾 Saving epoch checkpoint {epoch+1}")
            log.write("saving the model at the end of epoch %d, iters %d\n" % (epoch, trainer.total_steps))
            trainer.save_networks("latest")
            trainer.save_networks(epoch)

        # Validation
        print("\n🔍 Running validation...")
        trainer.eval()
        val_results = validate(trainer.model, val_cfg)
        val_writer.add_scalar("AP", val_results["AP"], trainer.total_steps)
        val_writer.add_scalar("ACC", val_results["ACC"], trainer.total_steps)
        # add
        val_writer.add_scalar("AUC", val_results["AUC"], trainer.total_steps)
        val_writer.add_scalar("TPR", val_results["TPR"], trainer.total_steps)
        val_writer.add_scalar("TNR", val_results["TNR"], trainer.total_steps)
        
        # Log validation metrics to wandb
        wandb.log({
            "val/AP": val_results["AP"],
            "val/ACC": val_results["ACC"],
            "val/AUC": val_results["AUC"],
            "val/TPR": val_results["TPR"],
            "val/TNR": val_results["TNR"],
            "epoch": epoch
        })
        
        # Save best checkpoint as wandb artifact
        if os.path.exists(os.path.join(cfg.ckpt_dir, "model_epoch_best.pth")):
            artifact = wandb.Artifact(
                name=f"{cfg.exp_name}_best_model",
                type="model",
                description=f"Best model checkpoint at epoch {epoch}"
            )
            artifact.add_file(os.path.join(cfg.ckpt_dir, "model_epoch_best.pth"))
            wandb.log_artifact(artifact)
        
        print(f"✓ Validation Results - AP: {val_results['AP']:.4f} | ACC: {val_results['ACC']:.4f} | AUC: {val_results['AUC']:.4f}")
        log.write(f"(Val @ epoch {epoch}) AP: {val_results['AP']}; ACC: {val_results['ACC']}\n")

        if cfg.earlystop:
            early_stopping(val_results["ACC"], trainer)
            if early_stopping.early_stop:
                if trainer.adjust_learning_rate():
                    print("📉 Learning rate dropped by 10, continuing training...")
                    log.write("Learning rate dropped by 10, continue training...\n")
                    early_stopping = EarlyStopping(patience=cfg.earlystop_epoch, delta=-0.002, verbose=True)
                else:
                    print("\n⏹️  Early stopping triggered")
                    log.write("Early stopping.\n")
                    break
        if cfg.warmup:
            # print(trainer.scheduler.get_lr()[0])
            trainer.scheduler.step()
        trainer.train()
    
    # Finish wandb run
    print("\n✓ Training complete! Finalizing W&B...")
    wandb.finish()
