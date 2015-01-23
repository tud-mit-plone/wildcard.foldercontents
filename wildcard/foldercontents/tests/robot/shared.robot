*** Settings ***

Resource  plone/app/robotframework/selenium.robot
Resource  plone/app/robotframework/keywords.robot

*** Keywords ***

Open Doc Menu
    [Arguments]  ${doc-id}

    Click Button  css=#folder-contents-item-${doc-id} button.dropdown-toggle
    Doc Menu Should Be Visible  ${doc-id}

Doc Menu Should Be Visible
    [Arguments]  ${doc-id}

    Element Should Be Visible  css=#folder-contents-item-${doc-id} ul.dropdown-menu

Doc Menu Should Not Be Visible
    [Arguments]  ${doc-id}

    Element Should Not Be Visible  css=#folder-contents-item-${doc-id} ul.dropdown-menu

Click Entry In Doc Menu
    [Arguments]  ${doc-id}  ${action-id}

    Open Doc Menu  ${doc-id}
    Click Link  css=#folder-contents-item-${doc-id} ul.dropdown-menu a.actionicon-object_buttons-${action-id}

Verify Overlay Is Visible
    Wait until keyword succeeds  10  1  Page Should Contain Element  css=.pb-ajax > div
    Element Should Be Visible  css=.pb-ajax > div

Verify Overlay Is Gone
    Wait until keyword succeeds  10  1  Page Should Not Contain Element  css=.pb-ajax > div

Wait For Ajax Reload
    Wait until keyword succeeds  10  1  Element Should Not Be Visible  kss-spinner
