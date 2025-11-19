#!/bin/bash
# Build script for AIGVDet Docker images

set -e

echo "======================================"
echo "AIGVDet Docker Build Script"
echo "======================================"
echo ""

# Function to build images
build_image() {
    local dockerfile=$1
    local tag=$2
    
    echo "Building $tag image..."
    docker build -f $dockerfile -t aigvdet:$tag .
    
    if [ $? -eq 0 ]; then
        echo "✅ Successfully built aigvdet:$tag"
    else
        echo "❌ Failed to build aigvdet:$tag"
        exit 1
    fi
    echo ""
}

# Parse arguments
case "$1" in
    gpu)
        echo "Building GPU image only..."
        build_image Dockerfile.gpu gpu
        ;;
    cpu)
        echo "Building CPU image only..."
        build_image Dockerfile.cpu cpu
        ;;
    all|"")
        echo "Building both CPU and GPU images..."
        build_image Dockerfile.cpu cpu
        build_image Dockerfile.gpu gpu
        ;;
    *)
        echo "Usage: $0 {gpu|cpu|all}"
        echo "  gpu  - Build GPU image only"
        echo "  cpu  - Build CPU image only"
        echo "  all  - Build both images (default)"
        exit 1
        ;;
esac

echo "======================================"
echo "Build completed!"
echo "======================================"
echo ""
echo "Available images:"
docker images | grep aigvdet
echo ""
echo "To run:"
echo "  GPU: docker run --gpus all -it --rm aigvdet:gpu"
echo "  CPU: docker run -it --rm aigvdet:cpu"
echo ""
echo "Or use docker-compose:"
echo "  docker-compose up aigvdet-gpu"
echo "  docker-compose up aigvdet-cpu"
