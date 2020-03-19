ui <- dashboardPage(
  dashboardHeader(title='Find Waste Containers in Amsterdam',titleWidth = 400),
  skin = 'red',
  #Sidebar
  dashboardSidebar(
    sidebarMenu(
      id = 'Menu',
      #user manual
      menuItem(
        'User Manual', tabName = 'manual',
        icon = icon('book')
      ),
      # Waste Guide
      menuItem(
        'About the App', tabName = 'aboutapp',
        icon = icon("info-circle")
      ),
      # Find Waste Containers
      menuItem(
        'Find Containers Near You', tabName = 'search',
        icon = icon('recycle')
      )
    ),
    conditionalPanel(
      condition = "input.Menu == 'search'",
      # post code input
      textInput(inputId = "postcode",
                label = "Enter Your Post Code",
                placeholder = "1082XD"),
      #filter for container type
      pickerInput(
        "containertype",
        label = "Select Container Type",
        choices = levels(containertype),
        selected = levels(containertype),
        options = list(`actions-box` = T),
        multiple=T
      ),
      # action for submit
      actionButton(
        inputId = "submit", label = "Submit", block=T, icon = icon("refresh")
        )
    )
  ),
  # Body
  dashboardBody(
    tabItems(
      #user manual
      tabItem(tabName = 'manual',
              fluidRow(
                
                #how to use
                box(
                  width = 12,
                  status = 'primary',
                  htmlOutput(outputId = 'manual1'),
                  img(
                    src="garbagebin.jpeg"
                  )
                )
              )),
      # aboutapp
      tabItem(tabName = 'aboutapp',
              fluidRow(
                #about app
                box(
                  width = 12,
                  title = 'About this App',
                  solidHeader = T,
                  status = 'primary',
                  htmlOutput(outputId='manual0')
                )
              
              )),
      #map and list of containers
      tabItem(tabName = 'search',
              fluidRow(
                box(
                  width = 12,
                  height = 700,
                  status = 'primary',
                  leafletOutput(height = 600,outputId = "waste_map")
                )
              ))
    )
  )
)