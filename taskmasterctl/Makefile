NAME = taskmasterctl

DC = ldc2

DFLAGS = -of=$(NAME)
DEBUGFLAGS = -gc

DFILES = source/*.d

$(NAME):
	$(DC) $(DFLAGS) $(DFILES)

all: $(NAME)

fclean:
	rm -f $(NAME)

debug: fclean
	$(DC) $(DFLAGS) $(DEBUGFLAGS) $(DFILES)

re: fclean all

run: re
	./$(NAME)