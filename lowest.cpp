#if defined(WIN32)
# define IMPORT extern __declspec(dllimport)
#else
# define IMPORT extern
#endif

IMPORT void dllfn();

void lowestfn() {
	dllfn();
}
