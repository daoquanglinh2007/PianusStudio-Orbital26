# Run this to activate virtual environment and install neccessary packages for backend
python -m venv .venv
# source .venv/Scripts/activate # for Windows
source .venv/bin/activate # for Ubuntu
pip install -r requirements.txt

# Run this to start running backend
# uvicorn main:app --reload

# Run this to exit virtual environment
# deactivate