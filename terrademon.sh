RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
BLUE='\033[1;34m'
RESET='\033[0m'

function ctrl_c() {
    echo "${RED} Finishing TerraDemon. Wait a moment...${RESET} "
    sleep 1
    clear
    exit 0
}

function welcome_message() {
    echo ""
    echo ""
    echo "${RED}                           - Welcome to TerraDemon -                      ${RESET}"
    echo ""
    echo "${GREEN}      _______                       ______  ${RESET}"
    echo "${GREEN}     |       .-----.----.----.---.-|   _  \ .-----.--------.-----.-----.${RESET}"
    echo "${GREEN}     |.|   | |  -__|   _|   _|  _  |.  |   \|  -__|        |  _  |     | ${RESET}"
    echo "${GREEN}     '-|.  |-|_____|__| |__| |___._|.  |    |_____|__|__|__|_____|__|__| ${RESET}"
    echo "${GREEN}       |:  |                       |:  |    / ${RESET}"
    echo "${GREEN}       |::.|                       |::.. . /  ${RESET}"
    echo "${GREEN}       '---'                       '------'  ${RESET}"
    echo ""
    echo ""
    echo "                            - Principal / Rocket Development Team -                                            "
    echo "${YELLOW}                  https://github.com/carlos-ssh/terrademon            ${RESET}"
    echo ""
    sleep 1
}

function init_terraform() {
    echo "${PURPLE}++++++++++++++++++++++++${RESET}"
    echo "${PURPLE}Initialicing Terraform...${RESET}"
    terraform init 2>&1 | tee /dev/tty
    run_terraform_plan
    echo "${GREEN}Initialization success...${RESET}"
}

function open_vscode() {
    echo "${PURPLE}++++++++++++++++++++++++${RESET}"
    echo "${PURPLE}Opening VSCode from this directory...${RESET}"
    code . 2>&1 | tee /dev/tty
    sleep 2
}

function run_terraform_plan() {
    echo "${PURPLE}++++++++++++++++++++++++${RESET}"
    echo "${PURPLE}Running Terraform Plan...${RESET}"
    terraform plan 2>&1 | tee /dev/tty
    echo ""
}

function run_terraform_validate() {
    echo "${PURPLE}Validating Terraform files...${RESET}"
    run_terraform_plan
    terraform plan 2>&1 | tee /dev/tty
    echo "${PURPLE}Validation files done...${RESET}"
}

function run_terraform_apply() {
    echo "${PURPLE}Applying Terraform plan...${RESET}"
    terraform apply -auto-approve 2>&1 | tee /dev/tty
    echo "${PURPLE}Applied Terraform success...${RESET}"
}

function run_terraform_fmt() {
    echo "${PURPLE}Formatting Terraform files...${RESET}"
    find . -name '*.tf' | while read -r file; do
        echo "${GREEN}Formatting: ${file}${RESET}"
        terraform fmt -write=true "$file"
    done
    echo "${PURPLE}Files formated done...${RESET}"
}

function run_terraform_destroy() {
    echo "${PURPLE}++++++++++++++++++++++++${RESET}"
    echo "${PURPLE}Destroying resources from your cloud provider ...${RESET}"
    terraform destroy 2>&1 | tee /dev/tty
    echo "${GREEN}Destroyed success ...${RESET}"
}

function run_workspaces_show() {
    echo "${PURPLE}++++++++++++++++++++++++${RESET}"
    echo "${PURPLE}Name of the current workspace...${RESET}"
    terraform workspace show 2>&1 | tee /dev/tty

}

function run_terraform_workspaces() {
    echo "${PURPLE}++++++++++++++++++++++++${RESET}"
    echo "${PURPLE}Terraform workspaces information...${RESET}"
    echo "${BLUE}(l) list      List Workspaces${RESET}"
    echo "${BLUE}(s) select    Select a workspace  ${RESET}"
    echo "${BLUE}(d) delete    Delete a workspace${RESET}"
    echo "${BLUE}(n) new       Create a new workspace${RESET}"
    echo "${BLUE}(s) show      Show the name of the current workspace  ${RESET}"
    echo "${YELLOW}🔙 Press 'm' to go back to the main menu \c${RESET}"
    echo "${GREEN}"
    echo ""
    read -p "Type here: 👉 " choice
    echo "${RESET}"

    case "$choice" in
        [sS] ) run_workspaces_show ;;
        [mM] ) ;;
        * ) echo "Invalid choice. Please enter 'm' to go back to the main menu." ;;
    esac
}

function main_loop() {
    show_main_menu=true

    while true; do
        # clear
        # init_terraform
        if [ "$show_main_menu" = true ]; then

            echo "${PURPLE}================================================${RESET}"
            echo "${PURPLE}  TerraDemon running... ${RESET}"
            echo ""

            fswatch -1 > /dev/null 2>&1

            echo "${YELLOW}🧐 Select one option to continue 👇...${RESET}"
            echo "${BLUE}   🔁 (r) Restart TerraDemon ${RESET}"
            echo "${BLUE}   🚥 (p) Plan ${RESET}"
            echo "${BLUE}   🛑 (d) Destroy resources ${RESET}"
            echo "${BLUE}   🎬 (a) Apply (auto approve) ${RESET}"
            echo "${BLUE}   🧰 (f) Format Files ${RESET}"
            echo "${BLUE}   ✅ (v) Validate Files ${RESET}"
            echo "${BLUE}   📇 (w) Workspaces ${RESET}"
            echo "${BLUE}   💻 (o) Open VSCode ${RESET}"
            echo "${BLUE}   🚪 (q) Quit TerraDemon \c${RESET}"
            echo "${GREEN}"
            echo ""
            read -p "Type here: 👉 " choice
            echo "${RESET}"

            case "$choice" in
                [rR] ) break ;;
                [aA] ) run_terraform_apply ;;
                [dD] ) run_terraform_destroy ;;
                [pP] ) run_terraform_plan ;;
                [fF] ) run_terraform_fmt ;;
                [oO] ) open_vscode ;;
                [vV] ) run_terraform_validate ;;
                [wW] ) run_terraform_workspaces ;;
                [qQ] ) ctrl_c ;;
                * ) echo "Invalid choice. Please enter 'r', 'p', 'f', 'v', 'w' or 'q'." ;;
            esac
        else
            clear
            run_terraform_workspaces
            show_main_menu
        fi
    done
}

trap ctrl_c INT

welcome_message
echo "Initializing TerraDemon..."
# sleep 2

while true; do
    init_terraform
    main_loop
done
