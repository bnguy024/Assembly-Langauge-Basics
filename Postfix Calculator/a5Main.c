#include <stdio.h>
#include <stdlib.h>

/*  Constants  */
#define MAXOP   20
#define NUMBER  '0'
#define TOOBIG  '9'

extern int a_sp;
extern int val[];
extern char buf[];
extern int  bufp;

/*  Function prototypes  */
int push(int f);
int pop();
void clear();
int getop(char *s, int lim);
int getch();
void ungetch(int c);

int main(){
	int type;
	char s[MAXOP];
	int op2;
	
	while ((type = getop(s, MAXOP)) != EOF) {
		switch (type) {
		case NUMBER:
			push(atoi(s));
			break;
		case '+':
			push(pop() + pop());
			break;
		case '*':
			push(pop() * pop());
			break;
		case '-':
			op2 = pop();
			push(pop() - op2);
			break;
		case '/':
			op2 = pop();
			if (op2 != 0)
				push(pop() / op2);
			else
				printf("zero divisor popped\n");
			break;
		case '=':
			printf("\n%d\n\n", push(pop()));
			break;
		case 'c':
			clear();
			break;
		case TOOBIG:
			printf("%.20s ... is too long\n", s);
			break;
		default:
			printf("unknown command %c\n", type);
			break;}
	}
	return 0;
}
//END 
int getop(char *s, int lim){
	int i, c;
	while ((c = getch()) == ' ' || c == '\t' || c == '\n')
		;

	if (c < '0' || c > '9')
		return c;
	
	s[0] = c;
	for (i = 1; (c = getchar()) >= '0' && c <= '9'; i++)
		if (i < lim)
			s[i] = c;
	
	if (i < lim) {
		ungetch(c);
		s[i] = '\0';
		return NUMBER;
	} 
	else {
		while (c != '\n' && c != EOF)
			c = getchar();
		s[lim-1] = '\0';
		return TOOBIG;}}

