# JuMP
# A MILP+QP modelling langauge for Julia
# By Iain Dunning and Miles Lubin

# diet.jl
# Solve the classic "diet" problem.
# Based on http://www.gurobi.com/documentation/5.6/example-tour/diet_cpp_cpp

using JuMP
using Gurobi
setLPSolver(:Gurobi)

function SolveDiet()
  
  # Nutrition guidelines
  numCategories = 4
  categories = ["calories", "protein", "fat", "sodium"]
  minNutrition = [1800, 91, 0, 0]
  maxNutrition = [2200, Inf, 65, 1779]

  # Foods
  numFoods = 9
  foods = ["hamburger", "chicken", "hot dog", "fries",
           "macaroni", "pizza", "salad", "milk", "ice cream"]
  cost = [2.49, 2.89, 1.50, 1.89, 2.09, 1.99, 2.49, 0.89, 1.59]
  nutritionValues = [410 24 26 730;
                     420 32 10 1190;
                     560 20 32 1800;
                     380  4 19 270;
                     320 12 10 930;
                     320 15 12 820;
                     320 31 12 1230;
                     100  8 2.5 125;
                     330  8 10 180]

  # Build model
  m = Model(:Min)
 
  # Variables for nutrition info
  @defVar(m, minNutrition[i] <= nutrition[i=1:numCategories] <= maxNutrition[i])
  # Variables for which foods to buy
  @defVar(m, buy[i=1:numFoods] >= 0)
 
  # Objective - minimize cost
  @setObjective(m, sum{cost[i]*buy[i], i=1:numFoods})

  # Nutrition constraints
  for j = 1:numCategories
    @addConstraint(m, sum{nutritionValues[i,j]*buy[i], i=1:numFoods} == nutrition[j])
  end

  # Solve
  status = solve(m)
  println("RESULTS:")
  if status == :Optimal
    for i = 1:numFoods
      println("  $(foods[i]) = $(getValue(buy[i]))")
    end
  else
    println("  No solution")
  end

  # Limit dairy
  @addConstraint(m, buy[8] + buy[9] <= 6)
  status = solve(m)
  println("RESULTS:")
  if status == :Optimal
    for i = 1:numFoods
      println("  $(foods[i]) = $(getValue(buy[i]))")
    end
  else
    println("  No solution")
  end
   
end

SolveDiet()

