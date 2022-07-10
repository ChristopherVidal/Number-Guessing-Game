#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\n~~ Number Guessing Game ~~\n"

echo "Enter your username: "
read USERNAME_INPUT

USER_STATS=$($PSQL "select * from users where username='$USERNAME_INPUT'")

if [[ -n $USER_STATS ]]
then
  echo $USER_STATS | while IFS="|" read USERNAME GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
else
  echo "Welcome, $USERNAME_INPUT! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME_INPUT')")
fi

SECRET_NUMBER=$(( ($RANDOM % 1000) + 1 ))
GUESS_COUNTER=0

echo -e "\nGuess the secret number between 1 and 1000:"

while [[ ! $GUESS -eq $SECRET_NUMBER ]]
do
  (( GUESS_COUNTER++ ))
  read GUESS
  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    if [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    elif [[ $GUESS -lt $SECRET_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    fi
  else
    echo "That is not an integer, guess again:"
  fi
done

if [[ $GUESS -eq $SECRET_NUMBER ]]
then
  echo "You guessed it in $GUESS_COUNTER tries. The secret number was $SECRET_NUMBER. Nice job!"
fi
#increase games_played
UPDATE_GAMES_PLAYED_RESULT=$($PSQL "UPDATE USERS SET games_played=games_played+1 where username='$USERNAME_INPUT'")

BEST_GAME=$($PSQL "select best_game from users where username='$USERNAME_INPUT'")
if [[ -z $BEST_GAME || $BEST_GAME -gt $GUESS_COUNTER ]]
then
  UPDATE_BEST_GAME=$($PSQL "UPDATE USERS SET best_game=$GUESS_COUNTER WHERE username='$USERNAME_INPUT'")
fi





