#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <windows.h>
#include <shlwapi.h>      // For PathCombine()
#include <shlobj.h>       // For SHCreateDirectoryEx()
#include <iostream>
#include <objbase.h>      // For `CoInitialize`
#include <initguid.h>     // Required for `IShellLink`
#include <shobjidl.h>     // Required for `IShellLink`
#include <ctype.h>        // Required for `toupper()`

/*
  Program Name    : setup.cpp
  Description     : Oracle Demo Installer
  Copyright       : Bond & Pollard Ltd 2025
  Author          : Ian Bond
  Date            : 8 March 2025
  
  User Guide      :
  The user will download appsdemo.zip archive extract the files, then
  run setup.exe to: 
  Prompt for name of database service, the pluggable databse.
  Prompt for name of the application owner and connection user, or accept default values.
  Prompt for the listener port, default 1521.
  Prompt for installation root directory APP_HOME and validate exists.
  Prompt for data directory  DATA_HOME and validate exists.
  If user specified a different APP_HOME directory from current, move app files.
  If user specified a different DATA_HOME directory from current, move data files.
  Create set_env.bat
  Create set_env.sql
  Create auto_install.sql
  TBC: Create compile_packages - find all pls package files and add to script. Need to compile 
  in correct sequence due to dependencies.
  Execute SQL script auto_install.sql to create db objects, compile packages.
  Copy the startora.bat script to the desktop.
  
  MODIFICATION HISTORY
  
  Date          Version     Author          Description
  =======================================================================================================================
  08/03/2025    1.00        IAB             Created.
  06/04/2026    1.01        IAB             Amend to allow install in current directory without creating mew directories
                                            and copying files. If installing to current directory do not add dbservice and
                                            app_owner to path. This makes installation easier when you download the demo
                                            app from a GitHub repository into a specified directory and just want to install it
                                            there.
  
 */
 
// Log message, optionally display to screen 
static void log_event_v(const char *format, bool display, va_list args) {
    FILE *log_file = std::fopen("install.log", "a");
    if (!log_file) {
        printf("Error: Could not open install.log for writing.\n");
        return;
    }
    va_list args_copy;
    va_copy(args_copy, args);
    vfprintf(log_file, format, args);
    std::fprintf(log_file, "\n");
    if (display) {
        vprintf(format, args_copy);
        std::putchar('\n');
    }
    va_end(args_copy);
    std::fclose(log_file);
}

// Write message to log only
void log_event(const char *format, ...) {
    va_list args;
    va_start(args, format);
    log_event_v(format, false, args);
    va_end(args);
}

// Write message to log and display on screen
void log_event_display(const char *format, ...) {
    va_list args;
    va_start(args, format);
    log_event_v(format, true, args);
    va_end(args);
}


void display_intro() {
    log_event_display("********************************************");
    log_event_display("*                                          *");
    log_event_display("*      ORACLE DEMO APPLICATION SETUP       *");
    log_event_display("*                                          *");
    log_event_display("*      (c) Bond & Pollard Ltd 2026         *");
    log_event_display("*                                          *");
    log_event_display("********************************************");
    log_event_display("\nPREREQUISITES");
    log_event_display("You must install Oracle first");
    log_event_display("\nINSTRUCTIONS");
    log_event_display("This program will install the Oracle demo application.");
    log_event_display("You will be prompted to enter the parameters required to configure the demo app.");
    log_event_display("Press ENTER to accept the default values, or enter your own preferences.");
    log_event_display("Check the log for errors.");
}

void log_install_param( const char *source_dir, 
                        const char *dbservice, 
                        const char *port, 
                        const char *db_connect, 
                        const char *app_owner,
                        const char *connect_user,
                        const char *app_home,
                        const char *sql_app_home,
                        const char *data_home,
                        const char *sql_data_home
                        ) {
    log_event_display("=======================");
    log_event_display("INSTALLATION PARAMETERS");
    log_event_display("=======================");
    log_event_display("Setup started in                     : %s", source_dir);
    log_event_display("Database Service                     : %s", dbservice);
    log_event_display("Listener Port                        : %s", port);
    log_event_display("Database Connection                  : %s", db_connect);
    log_event_display("Application Owner (APP_OWNER)        : %s", app_owner);
    log_event_display("Connection User (CONNECT_USER)       : %s", connect_user);
    log_event_display("Application Home Directory (APP_HOME): %s", app_home);
    log_event_display("Application Home SQL (SQL_APP_HOME)  : %s", sql_app_home);
    log_event_display("Data Home Directory (DATA_HOME)      : %s", data_home);
    log_event_display("Data Home SQL (SQL_DATA_HOME)        : %s", sql_data_home);
    log_event_display("Setup Log                            : %s\\install.log", source_dir);
}

void notify_complete(const char *source_dir, 
                        const char *dbservice, 
                        const char *port, 
                        const char *db_connect, 
                        const char *app_owner,
                        const char *connect_user,
                        const char *app_home,
                        const char *sql_app_home,
                        const char *data_home,
                        const char *sql_data_home
                        ) {
    log_install_param(source_dir, dbservice, port, db_connect, app_owner, connect_user, app_home, sql_app_home, data_home, sql_data_home);
    log_event_display("\n\nInstallation complete. Press RETURN to exit.");
    
    while (getchar() != '\n');  // Flush input buffer
    getchar();  // Wait for Enter
}

bool confirm_continue(const char *message) {
    char response;
    printf("\n");
    
    while (true) {
        std::cout << message;
        std::cin >> response;
        
        // Convert response to uppercase
        response = toupper(response);

        if (response == 'Y') {
            return true;
        } else if (response == 'N') {
            return false;
        } else {
            std::cout << "Invalid input. Please enter 'Y' for Yes or 'N' for No.\n";
        }
    }
}

void uppercase_drive_letter(char *path) {
    if (isalpha(path[0]) && path[1] == ':') {  // Check if it's a drive letter
        path[0] = toupper(path[0]);  // Convert to uppercase
    }
}

// Function to create a Windows shortcut on the desktop
void create_shortcut_on_desktop(const char *bat_file_path, const char *app_home, const char *shortcut_name) {
    HRESULT hr;
    IShellLink *shellLink = NULL;
    IPersistFile *persistFile = NULL;

    char modified_target[MAX_PATH];
    char modified_working_dir[MAX_PATH];

    // Copy and convert paths to uppercase
    snprintf(modified_target, sizeof(modified_target), "%s", bat_file_path);
    snprintf(modified_working_dir, sizeof(modified_working_dir), "%s", app_home);

    uppercase_drive_letter(modified_target);
    uppercase_drive_letter(modified_working_dir);

    // Initialize COM
    hr = CoInitialize(NULL);
    if (FAILED(hr)) {
        log_event_display("Error: Failed to initialize COM. HRESULT: 0x%X", hr);
        return;
    }

    // Create IShellLink instance
    hr = CoCreateInstance(CLSID_ShellLink, NULL, CLSCTX_INPROC_SERVER, IID_IShellLink, (void **)&shellLink);
    if (SUCCEEDED(hr)) {
        shellLink->SetPath(modified_target);
        shellLink->SetWorkingDirectory(modified_working_dir);
        shellLink->SetDescription("Start Oracle Application");

        hr = shellLink->QueryInterface(IID_IPersistFile, (void **)&persistFile);
        if (SUCCEEDED(hr)) {
            WCHAR wide_shortcut_path[MAX_PATH];
            char desktop_path[MAX_PATH];
            char shortcut_path[MAX_PATH];

            if (SHGetFolderPath(NULL, CSIDL_DESKTOP, NULL, 0, desktop_path) != S_OK) {
                log_event_display("Error: Could not retrieve desktop path.");
                return;
            }

            snprintf(shortcut_path, sizeof(shortcut_path), "%s\\%s.lnk", desktop_path, shortcut_name);
            MultiByteToWideChar(CP_ACP, 0, shortcut_path, -1, wide_shortcut_path, MAX_PATH);
            
            hr = persistFile->Save(wide_shortcut_path, TRUE);
            persistFile->Release();
        }

        shellLink->Release();
    }

    CoUninitialize();
}


void copy_and_rename_to_desktop(const char *source_file, const char *app_owner) {
    char desktop_path[MAX_PATH];
    char destination_file[MAX_PATH];

    // Get the current user's desktop directory
    if (SHGetFolderPath(NULL, CSIDL_DESKTOP, NULL, 0, desktop_path) != S_OK) {
        log_event_display("Error: Could not retrieve desktop path.");
        return;
    }

    // Construct the new file path with `app_owner`
    snprintf(destination_file, sizeof(destination_file), "%s\\%s.bat", desktop_path, app_owner);

    // Copy and rename the file
    if (!CopyFile(source_file, destination_file, FALSE)) {
        log_event_display("Error: Failed to copy %s to %s", source_file, destination_file);
    } else {
        log_event_display("Success: Copied %s to %s", source_file, destination_file);
    }
}

void show_progress_bar(int percent, short position_row) {
    HANDLE hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
    COORD pos = {0, position_row};  // Position the progress bar
    SetConsoleCursorPosition(hConsole, pos);

    printf("[");
    for (int i = 0; i < 50; i++) {
        if (i < percent / 2) {
            SetConsoleTextAttribute(hConsole, FOREGROUND_GREEN);
            printf("#");
        } else {
            SetConsoleTextAttribute(hConsole, FOREGROUND_RED);
            printf("-");
        }
    }
    SetConsoleTextAttribute(hConsole, FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE); // Reset color
    printf("] %d%%", percent);
}

void trim_whitespace(char *str) {
    int start = 0, end = strlen(str) - 1;

    // Trim leading spaces
    while (str[start] == ' ') start++;

    // Trim trailing spaces and newlines
    while (end > start && (str[end] == ' ' || str[end] == '\n' || str[end] == '\r')) end--;

    str[end + 1] = '\0';  // Null-terminate after last valid character
    memmove(str, str + start, strlen(str) - start + 1);  // Shift string left if needed
}

// Function to prompt user with a custom message and default value
void prompt_string(const char *message, char *input, int size, const char *default_value) {
    printf("%s (Press Enter for default: '%s'): ", message, default_value);
    fgets(input, size, stdin);

    // Remove newline character
    input[strcspn(input, "\n")] = 0;

    // If input is empty, use the default value
    if (strlen(input) == 0) {
        strcpy(input, default_value);
    }
 }

void get_current_directory(char *buffer, size_t size) {
    char exe_path[MAX_PATH];

    // Get the full path of the executable
    GetModuleFileName(NULL, exe_path, MAX_PATH);

    // Find the last backslash '\' to isolate the directory
    char *last_slash = strrchr(exe_path, '\\');
    if (last_slash) {
        *last_slash = '\0';  // Remove the executable name, keeping only the directory
    }

    // Copy the directory path to the buffer
    snprintf(buffer, size, "%s", exe_path);
}

// Function to check if a directory exists
int directory_exists(const char *path) {
    struct stat info;
    if (stat(path, &info) != 0) {
        return 0;  // Path does not exist
    }
    return (info.st_mode & S_IFDIR) ? 1 : 0;  // Check if it's a directory
}


// Generic function to replace all occurrences of `to_replace` with `replacement`
void replace_substring(const char *input, char *output, const char *to_replace, const char *replacement) {
    int i = 0, j = 0;
    int len = strlen(input);
    int to_replace_len = strlen(to_replace);
    int rep_len = strlen(replacement);

    while (i < len) {
        // Check if `to_replace` matches at this position
        if (strncmp(&input[i], to_replace, to_replace_len) == 0) {
            strcpy(&output[j], replacement);  // Copy replacement string
            j += rep_len;  // Move output index
            i += to_replace_len;  // Skip past `to_replace`
        } else {
            output[j++] = input[i++];  // Copy normal characters
        }
    }
    output[j] = '\0';  // Null-terminate output
}

void make_app_path(const char *input, char *target, int target_size, char *dbservice, char *app_owner) {
    // Add the database service name and app owner to give a unique installation path for the application
    // If the root directory does not end with a directory separator, then add one.
    size_t len = strlen(input);
    if (len > 0 && input[len - 1] == '\\') {
        snprintf(target, target_size, "%s%s%s%s", input, dbservice, "\\", app_owner);
    } else {
        snprintf(target, target_size, "%s%s%s%s%s", input, "\\", dbservice, "\\", app_owner);
    }  
}

bool path_valid(const char* path){
    bool test_path = true;
    int len = strlen(path);
    int i=0;
    
    while (i < len) {
      if (path[i] == '&'|| path[i] == ' ') {
        test_path=false;
      }
      i++;
    }
    return test_path;
}

    
// Function to prompt user for a directory path
void prompt_directory(const char *message, char *input, int size, const char *default_value, char *target, int target_size, char *dbservice, char *app_owner, bool strict) {
    prompt_string(message, input, size, default_value);
    bool valid_directory = false;
    
    
    // Validate installation directory path
   
    while (!valid_directory) {
        valid_directory=true;
        if(!directory_exists(input)) {
          printf("\nERROR: Directory does not exist, please enter a valid path: ");
          valid_directory=false;
        }
        if(!path_valid(input) && strict) {
          printf("\nERROR: The directory path must not contain spaces or &. Please enter a valid path: ");
          valid_directory=false;
        }
        if(!valid_directory) {
          fgets(input, size, stdin);
          input[strcspn(input, "\n")] = 0;
        }
    }
   
    trim_whitespace(input);
    
    // if installing to current directory then do not add dbservice and app_owner to path
    if (strcmp(input,default_value) !=0) {
      make_app_path(input, target, target_size, dbservice, app_owner);    // Make path unique to dbservice and app_owner
    }
    else {
      snprintf(target, target_size, "%s", default_value);                 // Make path the default do not add dbservice and app_owner
    }
    
}

void generate_set_env_sql(const char *dbservice, 
                          const char *port, 
                          const char *db_connect, 
                          const char *app_owner, 
                          const char *app_owner_pwd, 
                          const char *connect_user, 
                          const char *connect_pwd, 
                          const char *sql_app_home, 
                          const char *sql_data_home,
                          const char *app_home) {
    char filespec [MAX_PATH];
    snprintf(filespec, sizeof(filespec), "%s%s", app_home, "\\config\\set_env.sql");
    log_event_display("Creating %s...",filespec);
    FILE *file = fopen(filespec, "w");
    if (!file) {
        log_event_display("Error: Cannot open file for writing!");
        return;
    }
    
    fprintf(file, "/* \n");
    fprintf(file, "  NAME:    set_env.sql\n");
    fprintf(file, "  DESCRIPTION\n");
    fprintf(file, "           Created by setup to configure the Oracle application environent.\n");
    fprintf(file, "  SECURITY WARNING \n");  
    fprintf(file, "           You must keep the application owner/schema password secure. Do not allow any users\n");
    fprintf(file, "           or applications to connect to the database as the application owner.\n");
    fprintf(file, "           A separate connection user has been created for applications to\n");
    fprintf(file, "           connect to the database with.\n");
    fprintf(file, "  INSTRUCTIONS\n");
    fprintf(file, "           The setup program generates this script setting the following parameters:\n");
    fprintf(file, "           V_DBSERVICE    Database Service name, e.g. FREEPDB1, or PDBDEV, PDBPROD etc.\n");
    fprintf(file, "           V_APP_OWNER    Application owner/schema e.g. APPSDEMO.\n");
    fprintf(file, "           V_PWD          Password for the application owner schema.\n");
    fprintf(file, "                          See security warning above.\n");
    fprintf(file, "           V_CONNECT_USER Users and applications connect to the database as this user, e.g. DEMO_CONNECT. \n");
    fprintf(file, "                          This user does not own the application's schema objects, and has limited privileges.\n");
    fprintf(file, "           V_CONNECT_PWD  Password for V_CONNECT_USER.\n");
    fprintf(file, "           V_PORT         Oracle database listener port, default 1521.\n");
    fprintf(file, "           V_DBCONNECT    Connect to DB Service.\n");
    fprintf(file, "           V_APP_HOME     Application home directory path.\n");
    fprintf(file, "           V_DATA_HOME    Data home directory path (import / export, user files etc.)\n");
    fprintf(file, "*/\n");
    fprintf(file, "SET ESCAPE ON\n");
    fprintf(file, "DEFINE v_dbservice = %s\n",dbservice);
    fprintf(file, "DEFINE v_app_owner = %s\n",app_owner);
    fprintf(file, "ACCEPT v_pwd PROMPT \"Enter the password for %s: \" \n",app_owner);
    fprintf(file, "DEFINE v_connect_user = %s\n",connect_user);
    fprintf(file, "ACCEPT v_connect_pwd PROMPT \"Enter the password for the database connection user %s: \" \n",connect_user);
    fprintf(file, "DEFINE v_port = %s\n",port);
    fprintf(file, "DEFINE v_dbconnect = %s\n",db_connect);
    fprintf(file, "-- Application Home directory.\n");
    fprintf(file, "-- Note that where directory names contain a special character such as &, you must precede each special character with the \\ escape character.\n");
    fprintf(file, "-- You will need to SET ESCAPE ON first.\n");
    fprintf(file, "-- The directory name separator \\ will also need to be preceded by a \\ escape character.\n");
    fprintf(file, "DEFINE v_app_home = \"%s\"\n",sql_app_home);     // Enclose path in double quotes
    fprintf(file, "-- Data Home directory.\n");
    fprintf(file, "-- This is the location of the user data directories.\n");
    fprintf(file, "-- Do not include spaces or special characters such as & in the directory name.\n");
    fprintf(file, "DEFINE v_data_home = \"%s\"\n", sql_data_home);  // Enclose path in double quotes

    fclose(file);
    log_event_display("SQL script generated: %s", filespec);
}

void generate_set_env_bat(const char *dbservice, 
                          const char *port, 
                          const char *db_connect, 
                          const char *app_owner, 
                          const char *app_owner_pwd, 
                          const char *connect_user, 
                          const char *connect_pwd, 
                          const char *app_home, 
                          const char *data_home) {
    char filespec [MAX_PATH];
    snprintf(filespec, sizeof(filespec), "%s%s", app_home, "\\config\\set_env.bat");
    log_event_display("Creating %s...",filespec);
    FILE *file = fopen(filespec, "w");
    if (!file) {
        log_event_display("Error: Cannot open file for writing!");
        return;
    }

    fprintf(file, "REM Program   : set_env.bat\n");
    fprintf(file, "REM Decription: Generated by setup to set the environment variables for the Oracle application.\n");
    fprintf(file, "REM Parameters:\n");
    fprintf(file, "REM             dbservice       Database service name for the pluggable database.\n");
    fprintf(file, "REM                             Default is FREEPDB1. Alteratively specify a name for \n");
    fprintf(file, "REM                             a specific environment e.g. DEV, TEST, or PROD.\n");
    fprintf(file, "REM             app_owner       Name of user/schema that owns the application.\n");
    fprintf(file, "REM             connect_user    Applications connect to database via this user\n");
    fprintf(file, "REM             connect_pwd     Password for connect_user. By default the user will be prompted to\n");
    fprintf(file, "REM                             enter this password. If this script is called with the first argument STARTORA,\n");
    fprintf(file, "REM                             it will not prompt for the password.\n");
    fprintf(file, "REM             port            Oracle database listener port, default 1521.\n");
    fprintf(file, "REM             dbconnect       Database connection string, including hostname and port.\n");
    fprintf(file, "REM             app_home        Root installation directory for your application.\n");
    fprintf(file, "REM             data_home       User data directory (data import/export) - must not contain spaces.\n");
    fprintf(file, "REM                             or special characters.\n");
    fprintf(file, "REM INSTRUCTIONS:\n");
    fprintf(file, "REM             Call this batch file from your operating system scripts to set\n");
    fprintf(file, "REM             the required environment variables for the Oracle application.\n");
    fprintf(file, "REM             Users and Applications must connect to the database as connect_user, and the user must be\n"); 
    fprintf(file, "REM             prompted to enter the password. Call the set_env.bat script as follows:\n");
    fprintf(file, "REM                 CALL ..\\config\\SET_ENV\n");
    fprintf(file, "REM             To call the script without prompting for the password, e.g. from startora.bat\n");
    fprintf(file, "REM             which starts the Oracle database, and does not need to connect to the database as the\n");
    fprintf(file, "REM             connect_user, you may specify the first argument STARTORA as follows:\n");
    fprintf(file, "REM                 CALL ..\\config\\SET_ENV STARTORA\n");
    fprintf(file, "SET DBSERVICE=%s\n",dbservice);
    fprintf(file, "SET APP_OWNER=%s\n",app_owner);
    fprintf(file, "SET CONNECT_USER=%s\n",connect_user);
    fprintf(file, "SET PORT=%s\n",port);
    fprintf(file, "SET DBCONNECT=%s\n",db_connect);
    fprintf(file, "SET APP_HOME=\"%s\"\n",app_home);  // Enclose path in double quotes
    fprintf(file, "REM Do NOT include spaces or special characters in this directory name. We cannot enclose this variable in quotes\n");
    fprintf(file, "REM as we will need to add a filename later and enclose the whole path and filename in quotes.\n");
    fprintf(file, "SET DATA_HOME=%s\n",data_home);    //Do NOT enclose path in double quotes as other scripts need to append directories
    fprintf(file, "IF \"%%1\"==\"STARTORA\" GOTO END\n");
    fprintf(file, "SET /P CONNECT_PWD=Enter the password for %s: \n",connect_user);
    fprintf(file, ":END\n");
    
    fclose(file);
    log_event_display("Script generated: %s", filespec);
}

void generate_auto_install_sql(const char *dbservice, 
                           const char *port, 
                           const char *db_connect, 
                           const char *app_owner, 
                           const char *app_owner_pwd, 
                           const char *connect_user, 
                           const char *connect_pwd, 
                           const char *sql_app_home, 
                           const char *sql_data_home,
                           const char *app_home) {
    char filespec [MAX_PATH];
    snprintf(filespec, sizeof(filespec), "%s%s", app_home, "\\install\\auto_install.sql");
    log_event_display("Creating %s...",filespec);
    FILE *file = fopen(filespec, "w");
    if (!file) {
        log_event_display("Error: Cannot open file for writing!");
        return;
    }
  
    fprintf(file, "/* NAME:    auto_install.sql \n");
    fprintf(file, "   DESCRIPTION\n");
    fprintf(file, "            Created by setup to automatically:\n");
    fprintf(file, "            1. Create schema (tables, indexes, constraints, triggers etc).\n");
    fprintf(file, "            2. Create a connection user with restricted privileges.\n");
    fprintf(file, "            3. Load seed data into the database tables.\n");
    fprintf(file, "            4. Compile all packages.\n");
    fprintf(file, "*/ \n");
    fprintf(file, "-- Handle special characters e.g. ampersand & in directory names and strings.\n");
    fprintf(file, "-- You must escape the directory delimiters so use \\\\ not \\ \n");
    fprintf(file, "SET ESCAPE ON\n");
    fprintf(file, "DEFINE v_app_root=\"%s\"\n",sql_app_home);
    fprintf(file, "@'&v_app_root\\\\config\\\\set_env'\n");
    fprintf(file, "ACCEPT v_sys_pwd CHAR PROMPT 'Enter SYS password: '\n");
    fprintf(file, "CONNECT SYS/&v_sys_pwd@&v_dbconnect AS SYSDBA\n");
    fprintf(file, "@'&v_app_home\\\\install\\\\install_schema'     \"&v_dbservice\" \"&v_dbconnect\" \"&v_app_owner\" \"&v_pwd\" \"&v_connect_user\" \"&v_connect_pwd\" \"&v_app_home\" \"&v_data_home\" \n");
    fprintf(file, "@'&v_app_home\\\\install\\\\seed_data'          \"&v_dbservice\" \"&v_dbconnect\" \"&v_app_owner\" \"&v_pwd\"  \n");
    fprintf(file, "@'&v_app_home\\\\install\\\\compile_packages'   \"&v_dbservice\" \"&v_dbconnect\" \"&v_app_owner\" \"&v_pwd\" \"&v_app_home\" \"&v_connect_user\"  \"&v_connect_pwd\" \n");
    fprintf(file, "@'&v_app_home\\\\install\\\\lock_schema'        \"&v_dbservice\" \"&v_dbconnect\" \"&v_app_owner\" \"&v_sys_pwd\" \n");
    fprintf(file, "EXIT\n");
    fclose(file);
    log_event_display("SQL script generated: %s", filespec);
}


bool move_file_safe(const char* src, const char* dst) {
    if (!MoveFileEx(src, dst, MOVEFILE_COPY_ALLOWED | MOVEFILE_REPLACE_EXISTING)) {
        log_event_display("Error moving file: %s -> %s (Error: %lu)\n", src, dst, GetLastError());
        return false;
    }
    log_event("Moved file: %s -> %s", src, dst);
    return true;
}



void move_directory(const char *source, const char *destination, short progress_bar_row, bool move_app_home) {
    WIN32_FIND_DATA findFileData;
    HANDLE hFind;
    char sourcePath[MAX_PATH];
    char destPath[MAX_PATH];
    int fileCount = 0, filesCopied = 0;

    // Ensure parent directories exist
    if (SHCreateDirectoryEx(NULL, destination, NULL) != ERROR_SUCCESS &&
        GetLastError() != ERROR_ALREADY_EXISTS) {
        log_event_display("Error: Could not create directory %s (Error Code: %lu)", destination, GetLastError());
        return;
    }

    // Construct search pattern: source\*
    snprintf(sourcePath, sizeof(sourcePath), "%s\\*", source);

    // Find first file in source directory
    hFind = FindFirstFile(sourcePath, &findFileData);
    if (hFind == INVALID_HANDLE_VALUE) {
        log_event_display("Error: Could not open source directory %s", source);
        return;
    }

    // Count total files for progress tracking
    do {
        if (!(findFileData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)) {
            fileCount++;
        }
    } while (FindNextFile(hFind, &findFileData) != 0);
    FindClose(hFind);

    // Restart file search
    hFind = FindFirstFile(sourcePath, &findFileData);
    if (hFind == INVALID_HANDLE_VALUE) {
        log_event_display("Error: Could not open source directory %s", source);
        return;
    }

    do {
        // Skip "." and ".."
        if (strcmp(findFileData.cFileName, ".") == 0 || strcmp(findFileData.cFileName, "..") == 0) {
            continue;
        }
        
        // Do not move the setup.log file
        if (strcmp(findFileData.cFileName, "install.log") == 0) {
            continue;
        }

        // Construct full source and destination paths
        snprintf(sourcePath, sizeof(sourcePath), "%s\\%s", source, findFileData.cFileName);
        snprintf(destPath, sizeof(destPath), "%s\\%s", destination, findFileData.cFileName);

        if (findFileData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
            // Skip the data directory so it remains in source when moving the app home
            if (move_app_home && _stricmp(findFileData.cFileName, "data") == 0) {
              log_event_display("...Skipping data directory during move");
              continue;
            }
            
            // Recursively move directory
            move_directory(sourcePath, destPath, progress_bar_row, move_app_home);
            
            // Remove directory after contents moved
            RemoveDirectory(sourcePath);
        } else {
            // Move file
            if (!MoveFileEx(sourcePath, destPath, MOVEFILE_COPY_ALLOWED | MOVEFILE_REPLACE_EXISTING)) {
                log_event_display("Error moving file: %s -> %s", sourcePath, destPath);
            } else {
                filesCopied++;
                int progress = (filesCopied * 100) / fileCount;
                show_progress_bar(progress, progress_bar_row);  // Update progress bar
                log_event("Moved file: %s -> %s", sourcePath, destPath);
            }
        }

    } while (FindNextFile(hFind, &findFileData) != 0);

    FindClose(hFind);
    printf("\n");  // Ensure newline after completion
    fflush(stdout);
}

int main() {
    char dbservice[20];
    char app_owner[20];
    char app_owner_pwd[20];
    char connect_user[20];
    char connect_pwd[20];
    char app_install_locn[MAX_PATH];
    char data_install_locn[MAX_PATH];
    char app_home[MAX_PATH];
    char sql_app_home[MAX_PATH];
    char data_home[MAX_PATH];
    char sql_data_home[MAX_PATH];
    char port[6];
    char db_connect[100];
    char source_file[MAX_PATH];
    char source_dir[MAX_PATH];
    char source_data_dir[MAX_PATH];
    char temp_path[MAX_PATH];
    char target_path[MAX_PATH]; // desktop shortcut
    char working_dir[MAX_PATH];
    int status = -1;
    short progress_bar_row;
    char exec_sql[MAX_PATH];
    bool move_app_home;
    CONSOLE_SCREEN_BUFFER_INFO csbi; // positioning progress bar
    
   
    // Display welcome banner and instructions
    display_intro();
   
    // Get the directory where setup.exe is running
    get_current_directory(source_dir, sizeof(source_dir));
    log_event_display("\nSetup is running from source directory: %s", source_dir);
    
    // Get the location of the application data files
    snprintf(source_data_dir, sizeof(source_data_dir),"%s%s", source_dir, "\\data");
    
    log_event_display("IMPORTANT: You must install Oracle before running this setup.");
    if (!confirm_continue("Do you want to continue with the installation (Y or N)?")) {
      log_event_display("Exiting setup before entering parameters.");
      return 0;
    }
    
    while (getchar() != '\n');  // Flush input buffer
    
    // Prompt user for set up configuration values such as 
    // installation root directory, passwords
    
    prompt_string("\nEnter the pluggable database service name",dbservice, sizeof(dbservice),"FREEPDB1");
    prompt_string("\nEnter the application owner username",app_owner, sizeof(app_owner),"APPSDEMO");
    prompt_string("\nEnter the connection username",connect_user, sizeof(connect_user),"DEMO_CONNECT");
    prompt_string("\nEnter the listener port",port, sizeof(port),"1521");
    
    // Prompt user application installation location, store in app_home
    log_event_display("\nSpecify the application home directory APP_HOME.");
    log_event_display("If specifying a different directory:");
    log_event_display("> Include the drive letter.");
    log_event_display("> Separate each directory with a single \\. ");
    log_event_display("> e.g. D:\\myapps\\demo");
    log_event_display("> Do not end with a \\ unless specifying just the drive root e.g. D:\\ ");
    log_event_display("> You may include spaces and ampersands & in the APP_HOME path. ");
    log_event_display("> Do not include quotes \" ");
    prompt_directory("Enter APP_HOME directory path", app_install_locn, sizeof(app_install_locn), source_dir, app_home, sizeof(app_home), dbservice, app_owner,false);

    
    // Create sql_app_home for sql scripts with escape character prior to directory delimiters.
    // If path contains ampersands insert escape characters in front of them
    replace_substring(app_home, temp_path, "\\", "\\\\");
    replace_substring(temp_path, sql_app_home, "&", "\\&");
  
    // Prompt user data installation location, store in data_home
    log_event_display("\nSpecify the data home directory DATA_HOME.");
    log_event_display("If specifying a different directory:");
    log_event_display("> Include the drive letter.");
    log_event_display("> Separate each directory with a single \\. ");
    log_event_display("> e.g. D:\\test\\demo");
    log_event_display("> Do not end with a \\ unless specifying just the drive root e.g. D:\\ ");
    log_event_display("> Spaces are not allowed in this path.");
    log_event_display("> Do not include ampersands &. ");
    log_event_display("> Do not include quotes \". ");
    prompt_directory("Enter the DATA_HOME data directory path", data_install_locn, sizeof(data_install_locn), source_dir, data_home, sizeof(data_home), dbservice, app_owner, true);

    snprintf(data_home, sizeof(data_home), "%s%s", data_home, "\\data");
    
    // Create sql_data_home for sql scripts with escape character prior to directory delimiters.
    // If path contains ampersands insert escape characters in front of them
    replace_substring(data_home, temp_path, "\\", "\\\\");
    replace_substring(temp_path, sql_data_home, "&", "\\&");

    // Database connection string
    snprintf(db_connect, sizeof(db_connect), "%s%s%s%s", "//localhost:", port, "/", dbservice);

  
    // Log user parameters
    log_install_param(source_dir, dbservice, port, db_connect, app_owner, connect_user, app_home, sql_app_home, data_home, sql_data_home);
 
    
    // Confirm user wishes to continue
    if (confirm_continue("Do you want to continue with the installation (Y or N)?")) {
        
        log_event_display("User confirmed installation to continue.");
        
        // APP_HOME setup
        if (strcmp(app_home, source_dir) !=0) {
          // Move application files to the target directory
          log_event_display("Creating APP_HOME. Moving files from %s to %s...\n", source_dir, app_home);
          GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &csbi);
          progress_bar_row = csbi.dwCursorPosition.Y + 2;  // Adjust dynamically
          move_app_home = true;
          move_directory(source_dir, app_home, progress_bar_row, move_app_home);
          log_event_display("APP_HOME created.");
        } else {
          log_event_display("APP_HOME is set to %s", app_home);
        }
        
        // DATA_HOME setup
        if (strcmp(data_install_locn, source_dir) != 0) {
          // Create the data directories
          log_event_display("Creating DATA_HOME. Moving files from %s to %s...\n", source_data_dir, data_home);
          GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &csbi);
          progress_bar_row = csbi.dwCursorPosition.Y + 2;  // Adjust dynamically
          move_app_home = false;
          move_directory(source_data_dir, data_home, progress_bar_row, move_app_home);
          log_event_display("DATA_HOME created.");
          RemoveDirectory(source_data_dir); // Delete the old data directory from the source location after move
        } else {
          log_event_display("DATA_HOME is set to %s", data_home);
        }
        
        // Create custom configuration scripts using the user defined parameters
        generate_set_env_sql(dbservice, port, db_connect, app_owner, app_owner_pwd, connect_user, connect_pwd, sql_app_home, sql_data_home, app_home);
        generate_set_env_bat(dbservice, port, db_connect, app_owner, app_owner_pwd, connect_user, connect_pwd, app_home, data_home);  
        generate_auto_install_sql(dbservice, port, db_connect, app_owner, app_owner_pwd, connect_user, connect_pwd, sql_app_home, sql_data_home, app_home);

         
        // Execute SQL*Plus to create database objects
        log_event_display("Creating database objects.");
        snprintf(exec_sql, sizeof(exec_sql), "%s%s%s", "sqlplus / as sysdba @\"",app_home,"\\install\\auto_install.sql\"");
        log_event_display("Executing: %s",exec_sql);
        system(exec_sql);
        log_event_display("Database objects created.");
        
        //Send startora.bat to desktop as a shortcut
        snprintf(target_path, sizeof(target_path), "%s\\com\\startora.bat", app_home);
        snprintf(working_dir, sizeof(working_dir), "%s\\com", app_home);

        // Create shortcut on the Desktop
        create_shortcut_on_desktop(target_path, working_dir, app_owner);
        log_event_display("Shortcut created on Desktop: %s", app_owner);
    
        // Tell user installation is complete
        notify_complete(source_dir, dbservice, port, db_connect, app_owner, connect_user, app_home, sql_app_home, data_home, sql_data_home);
        status=0;
    } else {
        log_event_display("Installation abandoned.");
        status=0;
    }
      
    return status;
}
