#include <stdio.h>
#include <stdlib.h> // for rand(), srand()
#include <time.h>   

int main() {
    int randomNumber;
    int guess;
    int numGuesses = 0;
    srand(time(0));
    randomNumber = (rand() % 100) + 1;

    printf("I have a number between 1 and 100.\n");

    do {
        printf("Your guess: ");
        scanf("%d", &guess);
        numGuesses++;

        if (guess > randomNumber) {
            printf("Too high. Try again.\n");
        } else if (guess < randomNumber) {
            printf("Too low. Try again.\n");
        } else {
            printf("You got it in only %d guesses!\n", numGuesses);
        }
    } while (guess != randomNumber);

    return 0;
}
