*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library    RPA.Browser.Selenium
Library    RPA.Tables
Library    RPA.HTTP
Library    RPA.PDF
Library    RPA.Archive
Library    Dialogs
Library    RPA.Robocorp.Vault

*** Tasks ***
Order robots from RobotSpareBin Industries Inc.
    Open RobotSpareBin from user input
    Get csv url from vault file and download it
    Fill in orders form from csv file and create an archive of the pdfs



*** Keywords ***
Open RobotSpareBin from user input
    ${order_url}=    Get Value From User    please enter the URL    # in this example the url provide is https://robotsparebinindustries.com/#/robot-order  
    Open Available Browser    ${order_url}    
Get csv url from vault file and download it
    ${url}=    Get Secret    url
    Download    ${url}[csv_url]    overwrite=True

Fill in one person's order
    [Arguments]    ${order}
    Set Selenium Speed    0.5  
    Click Button    xpath://*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]
    Select From List By Value    id:head    ${order}[Head]
    Wait Until Element Is Visible    xpath://*[@id="id-body-${order}[Body]"]
    Click Element    xpath://*[@id="id-body-${order}[Body]"]
    Input Text    xpath:/html/body/div/div/div[1]/div/div[1]/form/div[3]/input   ${order}[Legs]
    Input Text    xpath:/html/body/div/div/div[1]/div/div[1]/form/div[4]/input    ${order}[Address]
    Click Button    xpath://*[@id="preview"]
    Screenshot    xpath://*[@id="robot-preview-image"]    ${OUTPUT_DIR}/screenshots/${order}[Order number].png
    Click Button    xpath://*[@id="order"]
    ${pdf}=    Get Element Attribute    xpath://*[@id="order-completion"]    outerHTML
    Html To Pdf    ${pdf}    ${OUTPUT_DIR}/receipts/${order}[Order number].pdf    
    Add Watermark Image To Pdf    ${OUTPUT_DIR}/screenshots/${order}[Order number].png    ${OUTPUT_DIR}/receipts/${order}[Order number].pdf      ${OUTPUT_DIR}/receipts/${order}[Order number].pdf   
    Close Pdf    ${OUTPUT_DIR}/receipts/${order}[Order number].pdf           
    Click Button    xpath://*[@id="order-another"]

Fill in orders form from csv file and create an archive of the pdfs
    ${table}    Read table from CSV    orders.csv    header=True
    FOR    ${order}  IN  @{table}
        Run Keyword And Ignore Error    Fill in one person's order    ${order}    
    END
    Archive Folder With Zip        ${OUTPUT_DIR}/receipts/    ${OUTPUT_DIR}${/}archive-receipts



