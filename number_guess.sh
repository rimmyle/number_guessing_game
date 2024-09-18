#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
GUESSME=$(( RANDOM % 1000 + 1 ))
echo -e "Enter your username:\n"
read USERNAME

USER_ID=$($PSQL "select user_id from users where name='$USERNAME';")
if  [[ -z $USER_ID ]]
then
  NEW_USER=$($PSQL "insert into users(name) values('$USERNAME');")
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else
  COUNT_GAMES=$($PSQL "select count(*) from games where user_id=$USER_ID;")
  BEST_GAME=$($PSQL "select min(number_of_guesses) from games where user_id=$USER_ID;") 
  echo -e "\nWelcome back, $USERNAME! You have played $COUNT_GAMES games, and your best game took $BEST_GAME guesses."
fi

echo -e "\nGuess the secret number between 1 and 1000:\n"

read GUESS
NUMBER_OF_GUESSES=1
 
while [[ $GUESS != $GUESSME ]]
do
  while [[ ! $GUESS =~ ^[0-9]+$ ]]
  do
    echo -e "\nThat is not an integer, guess again:\n"
    read GUESS
  done

  if [[ $GUESS > $GUESSME ]]
  then 
    echo -e "\nIt's lower than that, guess again:"
  else
    echo -e "\nIt's higher than that, guess again:"
  fi
  read GUESS
  NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES + 1 ))
done

USER_ID=$($PSQL "select user_id from users where name='$USERNAME';")

ADD_GAME=$($PSQL "insert into games(user_id, number_of_guesses) values($USER_ID, $NUMBER_OF_GUESSES);")
echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $GUESSME. Nice job!"
