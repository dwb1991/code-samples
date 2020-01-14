#######----- Create the user interface -----########
## @author Daniel Bower, Chris Bolen
## This file generates the UI object, to be used 



ui = fluidPage(
  # Application title
  titlePanel("Beat AML Ex-Vivo inihibitor explorer"),
  
  # On the left, there will be a fixed sidebar to select options. 
  # In the end, we may move these inside each tab, as some are pretty specific
  sidebarLayout(
    sidebarPanel(width=3,  ## width the sidebar takes up (out of 12)
                 
      ## Input panel
      selectInput("drug", "Choose a drug:",drugs$X1),
      textInput("gene", "Choose a gene:",rownames(v)),
      selectInput("trait", "Choose a trait:",colnames(clinical)),
      numericInput("n","Input top/bottom % of data:", 10, min = 1, max = 50)
    ),
    
    # The main layout will use tabs. Each tab will have a different type of plot
    mainPanel( 
      navbarPage("   ",
               
        ##### Page 1 - Drug overview ######
        tabPanel("Drug Overview",
          
          # Drug Overview will show the barplot for now
          plotlyOutput("DrugBarplot")
          
          # (perhaps include a table descibing the number of samples later?)
          # splitLayout(
          #   cellWidths = c("50%", "50%"),
          #   plotlyOutput("DrugBarplot"), 
          #   plotlyOutput("result2")
          # )
        ), # end drugOverview tab panel
        
        
        
        ##### Page 2 - Clinical correlations ######
        tabPanel("Clinical",
           plotlyOutput("drugVsClin")
        ), # end clinical tab panel
        
        ##### Page 3 - Expression correlations #####
        tabPanel("Expression",
            plotlyOutput("drugvsExpr")
            ),
        ##### Insert more tab pages here ######
        tabPanel("Volcano",
            plotlyOutput("volcano")),
        tabPanel("Exome",
            plotlyOutput("WES"))
        
      ) # end navbarPage
  
      
    ) # end mainPanel
  ) # end sidebarLayout
)