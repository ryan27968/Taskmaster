#include <unistd.h>

int	main()
{
	for (int i = 0; i < 30; ++i)
	{
		write(1, "Hello\n", 6);
		usleep(250 * 1000);
	}
	return (0);
}