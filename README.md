# My shell configuration
I use WSL-Ubuntu-bash.
The provided .bashrc file adds the following modifications and functionality to the terminal:
- The terminal will print **SIGINT** and **SIGTSTP** when you press Ctrl + C and Ctrl + Z respectively.
- If a command fails/errors/has an exit status of 1, the terminal will print **✗ 1**.  
- When you are in a virtual environment, a pink **(env)** is prepended to $PS1.
- Virtual environments will automatically be activated if there is a virtual environment in the current or parent directory, and deactivated if there's not. Virtual environment folders must be named env, venv, venv3, or .venv for this feature to work.
    - If the user manually deactivates a virtual environment, the automatic activation is disabled for the current session.
    - You can choose whether or not to automatically activate virtual environments by running **$ toggle_auto_env_activation**. I have it enabled.
- The current working directory (cwd) part of $PS1 can be truncated to be shorter if its length exceeds some specified amount of characters.
    - The maximum allowed length of the cwd can be modified via the provided set_max_length function, for example: **$ set_max_length 59** (note: the function enforces that an odd integer number argument is provided). I have it set to 65.
- If you're in a directory with git version control, some information about the git repository is appended to $PS1.
    - This is formatted as (${branch_name} ↑${num_commits} ${num_staged_files}:${num_modified_files})
        - The number of commits is only shown if num_commits > 0.
        - The number of staged files and number of modified files is only shown if (num_staged_files > 0 || num_modified_files > 0).
    - You can choose whether or not to display git information by running **$ toggle_git_info**. I have it enabled.