/*
** (c) Bond & Pollard Ltd 2022
** This software is free to use and modify at your own risk.
** 
** Module Name   :
** Description   :
** 
**------------------------------------------------------------------------
** Modification History
**  
** Date            Name                 Description
**------------------------------------------------------------------------
** DD/MM/YYYY      <your name>          Program created
**   
*/

#include <iostream>
#include <string>
#include <vector>
#include <sstream>
#include <cstdlib>   // EXIT_SUCCESS / EXIT_FAILURE

int main(int argc, char* argv[]) {
  // easy to use: args as vector<string>
  std::vector<std::string> args(argv, argv + argc);

  // simple help
  if (argc > 1 && (args[1] == "-h" || args[1] == "--help")) {
    std::cout << "Usage: " << args[0] << " [options]\n"
              << "  -h, --help    Show this help\n";
    return EXIT_SUCCESS;
  }

  // example: read an int from first argument (safe parse)
  int value = 0;
  if (argc > 1) {
    std::istringstream iss(args[1]);
    if (!(iss >> value)) {
      std::cerr << "Invalid integer: " << args[1] << '\n';
      return EXIT_FAILURE;
    }
  }

  // main program body (replace with your code)
  std::cout << "Argument count: " << argc << '\n';
  for (int i = 0; i < argc; ++i) {
    std::cout << "argv[" << i << "] = " << args[i] << '\n';
  }
  std::cout << "Parsed value = " << value << '\n';

  return EXIT_SUCCESS;
}
