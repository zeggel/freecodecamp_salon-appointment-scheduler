#!/bin/bash

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

PSQL="psql --username=freecodecamp --dbname=salon --csv -t -c"


service_menu () {
  SERVICES=$($PSQL 'SELECT * FROM services')

  if [[ -n $1 ]]
  then
    echo -e "$1"
  fi

  while IFS=, read ID NAME
  do
    echo "$ID) $NAME"
  done <<< $SERVICES
}

while [[ -z $SERVICE_NAME ]]
do
  service_menu "$PROMPT"

  read SERVICE_ID_SELECTED

  if [[ -n $SERVICE_ID_SELECTED ]]
  then
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  fi

  if [[ -z $SERVICE_NAME ]]
  then
    PROMPT="I could not find that service. What would you like today?"
  fi
  echo ""
done

while [[ -z $CUSTOMER_PHONE ]]
do
  echo "What's your phone number?"
  read CUSTOMER_PHONE
  echo ""
done

IFS=, read CUSTOMER_ID CUSTOMER_NAME <<< $($PSQL "SELECT customer_id, name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
if [[ -z $CUSTOMER_ID ]]
then
  while [[ -z $CUSTOMER_NAME ]]
  do
    echo "I don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    echo ""
  done
  
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phOne, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
fi
IFS=, read CUSTOMER_ID CUSTOMER_NAME <<< $($PSQL "SELECT customer_id, name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

while [[ -z $SERVICE_TIME ]]
do
  echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME
  echo ""
done

RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
if [[ $RESULT == 'INSERT 0 1' ]]
then
  echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
fi