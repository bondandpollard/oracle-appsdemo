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
    std::cout << "Usage: " << args[0] << " [options]" << std::endl
              << "  [-h | --help]" << std::endl;
    return EXIT_SUCCESS;
  }

  // example: read an int from first argument (safe parse)
  int value = 0;
  if (argc > 1) {
    std::istringstream iss(args[1]);
    if (!(iss >> value)) {
      std::cerr << "Invalid integer: " << args[1] << std::endl;
      return EXIT_FAILURE;
    }
  }

  // main program body (replace with your code)
  std::cout << "Argument count: " << argc << std::endl;
  for (int i = 0; i < argc; ++i) {
    std::cout << "argv[" << i << "] = " << args[i] << std::endl;
  }
  std::cout << "Parsed value = " << value << std::endl;

  return EXIT_SUCCESS;
}
