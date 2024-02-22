#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~~~~~~~ Salon Scheduler ~~~~~~~~~~~~~\n"

# Menu for the services available

MAIN_MENU(){
  # Check if function called with error
  if [[ $1 ]]
  then 
  echo -e "\n$1"
  fi
  
  # get list of services from database
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  
  
  #read and display list of services
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME 
  do
    echo $SERVICE_ID\) $SERVICE_NAME
  done

  # ask for input 
  read SERVICE_ID_SELECTED
  
  #check validity of the input
  if [[  $SERVICE_ID_SELECTED =~ [1-5] ]]
  then
  echo this is a valid option
  # Ask for phone number
  echo -e "What is your phone number?\n"
  read CUSTOMER_PHONE
  # check if customer alrady in the database
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE' ")

    #if not in database add it
    if [[ -z $CUSTOMER_NAME ]]
    then
      #ask for customer_name 
      echo There is no record for that phone number, What is your name?
      read CUSTOMER_NAME

      INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      #echo $CUSTOMER_NAME

      #Ask for appointment time
      echo -e "\nWhat time would you like your appoinment?\n"
      read SERVICE_TIME

      #insert new customer into database
      INSERT_DATA=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ((SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'),$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
      
      #get the service name
      SERVICE_NAME=$($PSQL "SELECT name from services WHERE service_id = $SERVICE_ID_SELECTED")
      # print the appointment info
      echo -e "\nI have put you down for a $(echo $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME | sed -E 's/^ +| $//g')."
      else
      #Ask for appointment time
      echo -e "\nWhat time would you like your appoinment?\n"
      read SERVICE_TIME

      #insert new customer into database
      INSERT_DATA=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ((SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'),$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
      #get the service name
      SERVICE_NAME=$($PSQL "SELECT name from services WHERE service_id = $SERVICE_ID_SELECTED")
      echo this is in the database
      # print the appointment info
      echo -e "\nI have put you down for a $(echo $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME | sed -E 's/^ +| $//g')."
    fi

  #Process the invalid option
  else
  MAIN_MENU "Please choose a valid option"
  fi
  
}

MAIN_MENU