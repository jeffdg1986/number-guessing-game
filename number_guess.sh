#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=guessing_game -t --no-align -c"

function game(){
UPDATE_SECRET_NUMBER=$($PSQL "UPDATE game_records SET secret_number = $(( $RANDOM % 1000 + 1 )) WHERE username='$USER_NAME'")
GET_SECRET_NUMBER=$($PSQL "SELECT secret_number FROM game_records WHERE username='$USER_NAME'")
echo -e "Guess the secret number between 1 and 1000:"
read GUESS
GUESS_COUNT=0
while [ $GUESS != $GET_SECRET_NUMBER ]
do
if [[ $GUESS =~ ^-?[0-9]+$ ]]
  then
  if [[ $GET_SECRET_NUMBER -lt $GUESS ]]
    then
    echo "It's lower than that, guess again:"
    read GUESS
    GUESS_COUNT=$(( $GUESS_COUNT + 1 ))
  elif [[ $GET_SECRET_NUMBER -gt $GUESS ]]
    then
    echo "It's higher than that, guess again:"
    read GUESS
    GUESS_COUNT=$(( $GUESS_COUNT + 1 ))
fi
else
  echo "That is not an integer, guess again:"
  read GUESS
fi
done
  if [[ $GET_SECRET_NUMBER == $GUESS ]]
    then
    GUESS_COUNT=$(( $GUESS_COUNT + 1 ))
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM game_records WHERE username = '$USER_NAME'")
      if [[ -z $GAMES_PLAYED ]]
        then
        LOG_FIRST_GAME_GUESS_COUNT=$($PSQL "UPDATE game_records SET best_game = $GUESS_COUNT WHERE username = '$USER_NAME'")
        LOG_FIRST_GAME_PLAYED=$($PSQL "UPDATE game_records SET games_played = 1 WHERE username = '$USER_NAME'")
      else
        GET_BEST_GAME=$($PSQL "SELECT best_game FROM game_records WHERE username = '$USER_NAME'")
        GET_GAMES_PLAYED=$($PSQL "SELECT games_played FROM game_records WHERE username = '$USER_NAME'")
        UPDATE_GAMES_PLAYED=$($PSQL "UPDATE game_records SET games_played = $(( $GET_GAMES_PLAYED + 1 )) WHERE username = '$USER_NAME'")
        
          if [[ $GUESS_COUNT -lt $GET_BEST_GAME ]]
            then
            UPDATE_BEST_GAME=$($PSQL "UPDATE game_records SET best_game = $GUESS_COUNT WHERE username = '$USER_NAME'")
            fi
      fi
      echo -e "You guessed it in $GUESS_COUNT tries. The secret number was $GET_SECRET_NUMBER. Nice job!"
    fi
}
# Lookup username in number_guess.sql
echo -e "Enter your username:"
read USER_NAME
if [[ $USER_NAME ]]
then
CHECK_RECORDS=$($PSQL "SELECT username FROM game_records WHERE username = '$USER_NAME'")
# If username not found, insert in database
if [[ -z $CHECK_RECORDS ]]
then
echo -e "Welcome, $USER_NAME! It looks like this is your first time here."
ADD_USER=$($PSQL "INSERT INTO game_records(username) values('$USER_NAME')")
# run the game
game
# If username is found
else
GAMES_PLAYED=$($PSQL "SELECT games_played FROM game_records WHERE username = '$USER_NAME'")
BEST_GAME=$($PSQL "SELECT best_game FROM game_records WHERE username = '$USER_NAME'")
echo -e "Welcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
game
fi
fi
