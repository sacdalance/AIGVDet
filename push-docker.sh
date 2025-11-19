#!/bin/bash
# Docker Push Script for AIGVDet
# Pushes images to Docker Hub: sacdalance/thesis-aigvdet

set -e

VERSION="${1:-all}"
TAG="${2:-latest}"
REPOSITORY="sacdalance/thesis-aigvdet"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║     Docker Push Script - AIGVDet                          ║"
echo "║     Repository: ${REPOSITORY}"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

build_and_push_image() {
    local dockerfile=$1
    local image_tag=$2
    local version_tag=$3
    
    local local_tag="aigvdet:${image_tag}"
    local remote_tag="${REPOSITORY}:${version_tag}"
    local remote_latest_tag="${REPOSITORY}:${image_tag}"
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${YELLOW}🔨 Building ${image_tag} image...${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    docker build -f "${dockerfile}" -t "${local_tag}" -t "${remote_tag}" -t "${remote_latest_tag}" .
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to build ${image_tag} image${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Successfully built ${image_tag} image${NC}"
    echo ""
    
    echo -e "${YELLOW}📤 Pushing to Docker Hub...${NC}"
    
    # Push with version tag
    echo -e "${CYAN}  → Pushing ${remote_tag}...${NC}"
    docker push "${remote_tag}"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to push ${remote_tag}${NC}"
        exit 1
    fi
    
    # Push with latest tag
    echo -e "${CYAN}  → Pushing ${remote_latest_tag}...${NC}"
    docker push "${remote_latest_tag}"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to push ${remote_latest_tag}${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Successfully pushed ${image_tag} image to Docker Hub${NC}"
    echo ""
}

# Check if Docker is running
echo -e "${YELLOW}🔐 Checking Docker authentication...${NC}"
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running or not accessible${NC}"
    exit 1
fi

# Check if logged in
if ! docker info 2>&1 | grep -q "Username"; then
    echo -e "${YELLOW}⚠️  You may not be logged in to Docker Hub${NC}"
    echo -e "${YELLOW}Please run: docker login${NC}"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi
echo -e "${GREEN}✅ Docker is ready${NC}"
echo ""

# Build and push based on version
case "$VERSION" in
    gpu)
        echo -e "${YELLOW}Building and pushing GPU version only...${NC}"
        echo ""
        build_and_push_image "Dockerfile.gpu" "gpu" "${TAG}-gpu"
        ;;
    cpu)
        echo -e "${YELLOW}Building and pushing CPU version only...${NC}"
        echo ""
        build_and_push_image "Dockerfile.cpu" "cpu" "${TAG}-cpu"
        ;;
    all)
        echo -e "${YELLOW}Building and pushing both CPU and GPU versions...${NC}"
        echo ""
        build_and_push_image "Dockerfile.cpu" "cpu" "${TAG}-cpu"
        build_and_push_image "Dockerfile.gpu" "gpu" "${TAG}-gpu"
        ;;
    *)
        echo -e "${RED}Usage: $0 {gpu|cpu|all} [tag]${NC}"
        echo "  gpu  - Push GPU image only"
        echo "  cpu  - Push CPU image only"
        echo "  all  - Push both images (default)"
        echo "  tag  - Version tag (default: latest)"
        exit 1
        ;;
esac

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}🎉 All images pushed successfully!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${YELLOW}📦 Available images on Docker Hub:${NC}"

if [ "$VERSION" = "cpu" ] || [ "$VERSION" = "all" ]; then
    echo -e "${CYAN}  • ${REPOSITORY}:cpu${NC}"
    echo -e "${CYAN}  • ${REPOSITORY}:${TAG}-cpu${NC}"
fi

if [ "$VERSION" = "gpu" ] || [ "$VERSION" = "all" ]; then
    echo -e "${CYAN}  • ${REPOSITORY}:gpu${NC}"
    echo -e "${CYAN}  • ${REPOSITORY}:${TAG}-gpu${NC}"
fi

echo ""
echo -e "${YELLOW}🚀 Pull commands:${NC}"

if [ "$VERSION" = "cpu" ] || [ "$VERSION" = "all" ]; then
    echo "  CPU: docker pull ${REPOSITORY}:cpu"
fi

if [ "$VERSION" = "gpu" ] || [ "$VERSION" = "all" ]; then
    echo "  GPU: docker pull ${REPOSITORY}:gpu"
fi

echo ""
echo -e "${YELLOW}💡 View on Docker Hub:${NC}"
echo -e "${CYAN}  https://hub.docker.com/r/${REPOSITORY}${NC}"
echo ""
