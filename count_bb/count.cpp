#include <cstdio>
#include <cstdlib>

//#define INTERVAL 10000000
#define STARTSIZE 1024
int var;
void func() {};

extern "C" {
void countBlocks(unsigned long count, unsigned long inst)
{
	static unsigned long *counter_array = NULL;
	static unsigned long inst_count = 0;
	static size_t size = STARTSIZE;
	static unsigned long last = 0;
	static FILE *out;
	if (counter_array == NULL)
	{
		counter_array = (unsigned long *) calloc(size, sizeof(unsigned long));
		out = fopen("count.bb", "w");
	}
	if (count >= size)
	{
		size_t old_size = size;
		size *= 2;
		unsigned long *temp = counter_array;
		temp = (unsigned long *) realloc(counter_array, size * 
			sizeof(unsigned long));
		unsigned long i;
		if (temp != NULL)
		{
			counter_array = temp;
		}
		else
		{
			printf("ERROR: could not allocate\n");
		}
		for (i = old_size - 1; i < size; i++)
		{
			counter_array[i] = 0;
		}
	}
	if (count > last && count != -1UL)
	{
		last = count;
	}
	if (count == -1UL)
	{
		unsigned long i;
		//out = fopen("count.bb", "a");
	//	printf("FINAL LAST IS: %lu, SIZE IS %lu\n", last, size);
		fprintf(out, "T");
		for (i = 0; i <= last; i++)
		{
			if (counter_array[i] != 0)
			{
				fprintf(out, ":%lu:%lu ", i + 1, counter_array[i]);
			}
		}
		fprintf(out, "\n");
		free(counter_array);
		fclose(out);
		return;
	}
	inst_count += inst;
	if (inst_count >= INTERVAL)
	{
		unsigned long i;
		//out = fopen("count.bb", "a");
	//	printf("LAST IS: %lu, SIZE IS %lu\n", last, size);
		fprintf(out, "T");
		for (i = 0; i <= last; i++)
		{
			if (counter_array[i] != 0)
			{
				fprintf(out, ":%lu:%lu ", i + 1, counter_array[i]);
				counter_array[i] = 0;
			}
		}
		fprintf(out, "\n");
		//fclose(out);
		inst_count = 0;
	}
	counter_array[count]++;
	return;
}
} // end extern
