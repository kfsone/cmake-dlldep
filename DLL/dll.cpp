#include <iostream>

#if defined(WIN32)
# define EXPORT extern __declspec(dllexport)
#else
# define EXPORT extern
#endif

EXPORT void dllfn() {
	std::cout << "dllfn invoked\n";
}
