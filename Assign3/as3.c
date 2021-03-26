int main()
{
    int v[SIZE], gap, i, j, temp;

    // Initialize array to random positive integers mod 512
    for (i = 0; i < SIZE; i++)
        v[i] = rand() & 0x1FF;

    // Display the unsorted array
    printf("Unsorted array:\n");
    for (i = 0; i < SIZE; i++)
        printf("v[%d] = %d\n", i, v[i]);

    // Sort the array into descending order using a shell sort
    for (gap = SIZE / 2; gap > 0; gap /= 2) {
        for (i = gap; i < SIZE; i++) {
            for (j = i - gap; j >= 0 && v[j] < v[j + gap]; j -= gap) {
	      // Exchange out of order items
                temp = v[j];
                v[j] = v[j + gap];
                v[j + gap] = temp;
            }
        }
    }

    // Display the sorted array
    printf("\nSorted array:\n");
    for (i = 0; i < SIZE; i++)
        printf("v[%d] = %d\n", i, v[i]);

    return 0;
}

