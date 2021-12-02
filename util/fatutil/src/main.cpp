//============================================================================|
//  _______ _________          _______  _______                               |
//  (  ____ \\__   __/|\     /|(  ____ \(  ____ )                             |
//  | (    \/   ) (   | )   ( || (    \/| (    )|                             |
//  | (__       | |   | (___) || (__    | (____)|    By Hákon Hjaltalín.      |
//  |  __)      | |   |  ___  ||  __)   |     __)    Licensed under MIT.      |
//  | (         | |   | (   ) || (      | (\ (                                |
//  | (____/\   | |   | )   ( || (____/\| ) \ \__                             |
//  (_______/   )_(   |/     \|(_______/|/   \__/                             |
//============================================================================|

#include <cstdint>
#include <iostream>

int main(int argc, char** argv)
{
    std::cout << "\033[1;34mEther FAT12  Utility v1.0.0\033[0m\n";
    
    if (argc != 3)
        std::cout << "\033[1;31mUsage: fatutil [image] [path]\033[0m\n";
    
    //copy(argv[1], argv[2], buf, bpb);
    
    return 0;
}