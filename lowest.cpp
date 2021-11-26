#if defined(WIN32)
# define IMPORT extern __declspec(dllexport)
#else
# define IMPORT extern
#endif

IMPORT void dllfn();

void lowestfn() {
	dllfn();
}
