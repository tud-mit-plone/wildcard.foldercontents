*** Settings ***

Resource  plone/app/robotframework/selenium.robot
Resource  plone/app/robotframework/keywords.robot

Library  Remote  ${PLONE_URL}/RobotRemote

Suite Setup  Setup
Suite Teardown  Teardown

*** Keywords ***

Setup
    Open test browser
    Set Window Size  1024  768
    Enable autologin as  Manager
    Go to  ${PLONE_URL}

Teardown
    Close all browsers

*** Test Cases ***

Capture Interface Screenshot
    Go to  ${PLONE_URL}/folder_contents
    Capture Page Screenshot
