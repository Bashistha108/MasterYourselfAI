#!/bin/bash

# Master Yourself AI - Startup Script
# This script sets up and runs both backend and frontend

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if port is in use
port_in_use() {
    lsof -i :$1 >/dev/null 2>&1
}

# Function to setup backend
setup_backend() {
    print_status "Setting up backend..."
    
    cd backend
    
    # Check if Python is installed
    if ! command_exists python3; then
        print_error "Python 3 is not installed. Please install Python 3.8+ first."
        exit 1
    fi
    
    # Check if virtual environment exists
    if [ ! -d "venv" ]; then
        print_status "Creating virtual environment..."
        python3 -m venv venv
    fi
    
    # Activate virtual environment
    print_status "Activating virtual environment..."
    source venv/bin/activate
    
    # Install dependencies
    print_status "Installing Python dependencies..."
    pip install -r requirements.txt
    
    print_success "Backend setup completed!"
    cd ..
}

# Function to setup frontend
setup_frontend() {
    print_status "Setting up frontend..."
    
    cd frontend
    
    # Check if Flutter is installed
    if ! command_exists flutter; then
        print_error "Flutter is not installed. Please install Flutter SDK first."
        print_status "Visit: https://flutter.dev/docs/get-started/install"
        exit 1
    fi
    
    # Get Flutter dependencies
    print_status "Getting Flutter dependencies..."
    flutter pub get
    
    print_success "Frontend setup completed!"
    cd ..
}

# Function to run backend
run_backend() {
    print_status "Starting backend server..."
    
    cd backend
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Check if port 5000 is available
    if port_in_use 5000; then
        print_warning "Port 5000 is already in use. Backend might already be running."
    fi
    
    # Run the backend
    print_status "Running Flask backend on http://localhost:5000"
    python run.py &
    BACKEND_PID=$!
    
    cd ..
    
    print_success "Backend started with PID: $BACKEND_PID"
}

# Function to check if Android device is connected
check_android_device() {
    if command_exists adb; then
        # Check if any Android device is connected
        adb devices | grep -q "device$" && return 0
    fi
    return 1
}

# Function to run frontend
run_frontend() {
    print_status "Starting frontend..."
    
    cd frontend
    
    # Check if Flutter is available
    if ! command_exists flutter; then
        print_error "Flutter is not available. Please install Flutter SDK."
        exit 1
    fi
    
    # Check for Android device
    if check_android_device; then
        print_status "Android device detected! Running on Android..."
        flutter run -d android &
        FRONTEND_PID=$!
        print_success "Frontend started on Android device with PID: $FRONTEND_PID"
    else
        print_status "No Android device found. Running in Chrome..."
        flutter run -d chrome &
        FRONTEND_PID=$!
        print_success "Frontend started in Chrome with PID: $FRONTEND_PID"
    fi
    
    cd ..
}

# Function to stop all processes
stop_app() {
    print_status "Stopping all processes..."
    
    # Kill backend process
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null || true
        print_status "Backend stopped"
    fi
    
    # Kill frontend process
    if [ ! -z "$FRONTEND_PID" ]; then
        kill $FRONTEND_PID 2>/dev/null || true
        print_status "Frontend stopped"
    fi
    
    # Kill any remaining Python processes
    pkill -f "python.*run.py" 2>/dev/null || true
    pkill -f "flutter.*run" 2>/dev/null || true
    
    print_success "All processes stopped!"
}

# Function to show available devices
show_devices() {
    print_status "Checking available Flutter devices..."
    
    if command_exists flutter; then
        cd frontend
        flutter devices
        cd ..
    else
        print_error "Flutter is not installed"
    fi
}

# Function to show status
show_status() {
    print_status "Checking application status..."
    
    if port_in_use 5000; then
        print_success "Backend is running on port 5000"
    else
        print_warning "Backend is not running"
    fi
    
    # Check for Flutter processes
    if pgrep -f "flutter.*run" >/dev/null; then
        print_success "Frontend is running"
    else
        print_warning "Frontend is not running"
    fi
    
    # Check for Android devices
    if check_android_device; then
        print_success "Android device is connected"
    else
        print_warning "No Android device connected"
    fi
}

# Function to show help
show_help() {
    echo "Master Yourself AI - Startup Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  setup     - Setup both backend and frontend dependencies"
    echo "  start     - Start both backend and frontend (Android if connected, Chrome otherwise)"
    echo "  backend   - Start only backend"
    echo "  frontend  - Start only frontend (Android if connected, Chrome otherwise)"
    echo "  stop      - Stop all running processes"
    echo "  status    - Show status of running processes"
    echo "  devices   - Show available Flutter devices"
    echo "  help      - Show this help message"
    echo ""
    echo "Device Detection:"
    echo "  - Automatically detects Android devices via ADB"
    echo "  - Runs on Android if device is connected"
    echo "  - Falls back to Chrome if no Android device found"
    echo ""
    echo "Examples:"
    echo "  $0 setup    # First time setup"
    echo "  $0 start    # Run the complete app"
    echo "  $0 devices  # Check available devices"
    echo "  $0 stop     # Stop all processes"
}

# Main script logic
case "${1:-start}" in
    "setup")
        print_status "Setting up Master Yourself AI..."
        setup_backend
        setup_frontend
        print_success "Setup completed! Run '$0 start' to start the app."
        ;;
    "start")
        print_status "Starting Master Yourself AI..."
        setup_backend
        setup_frontend
        run_backend
        sleep 3  # Give backend time to start
        run_frontend
        print_success "App started! Backend: http://localhost:5000"
        print_status "Press Ctrl+C to stop all processes"
        
        # Wait for user interrupt
        trap stop_app INT
        wait
        ;;
    "backend")
        setup_backend
        run_backend
        print_status "Backend running. Press Ctrl+C to stop"
        trap stop_app INT
        wait
        ;;
    "frontend")
        setup_frontend
        run_frontend
        print_status "Frontend running. Press Ctrl+C to stop"
        trap stop_app INT
        wait
        ;;
    "stop")
        stop_app
        ;;
    "status")
        show_status
        ;;
    "devices")
        show_devices
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
