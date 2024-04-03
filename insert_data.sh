#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# clear database whenever script is run
echo $($PSQL "TRUNCATE games, teams")

#teams done first
# get major_id
index_team_id=1

#prend tous les items à partir de la ligne 2
tail -n +2 games.csv | while IFS="," read year round winner opponent winner_goals opponent_goals 
do
#selectionne les team_id de teams ou le nom match les winner ou les opponents du fichier CSV
  team_id_winner=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
  team_id_opponent=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")

  if [[ -z $team_id_winner ]]
    then
      # insert les valeurs 
      insert_winner_result=$($PSQL "INSERT INTO teams(team_id,name) VALUES($index_team_id,'$winner')")
      ((index_team_id++))
      fi

  if [[ -z $team_id_opponent ]]
    then
      # insert 
      insert_opponent_result=$($PSQL "INSERT INTO teams(team_id,name) VALUES($index_team_id,'$opponent')")
      ((index_team_id++))
      fi
done 

#read data from csv file and insert into games table
index=1

#le tail permet de ne pas prendre la première ligne en considération
tail -n +2 games.csv | while IFS="," read year round winner opponent winner_goals opponent_goals
do
#crée des ids pour chaque winner et chaque loser
  game_id=$index
  winner_id=$($PSQL "SELECT team_id FROM teams WHERE name = '$winner'")
  opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name = '$opponent'")

#On peut utilisé les IDs crée avant pour se référer directe a eux
#C'est plus propre comme ça!
  INSERT_FINAL_RESULTS=$($PSQL "INSERT INTO games
  (game_id, year, round, winner_id, opponent_id, winner_goals, opponent_goals) 
  VALUES($index, $year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals)")
  
#Rajoute 1 à l'index 
((index++))
done
