# Solve secret santa with Grover

This repo contains the revised code which began with [this](https://vincent.frl/quantum-secret-santa/) blog post. It shows how to solve a secret sant raffle using the Grover Search algorithm.
When executed the program will try to find a solution for 3 players:  Vincent Tess, and Uma, then prints the results to the terminal. The output should look like this: 
```
         | Vincent    | Uma        | Tess
 Vincent |     X      |    true    |    false   |
 Uma     |    false   |     X      |    true    |
 Tess    |    true    |    false   |     X      |
```
This menas that Vincent should get a small git for Uma, Uma for Tess and Tess for Vincent (and don't forget the poem!)

### How to use
- Make sure you have [.net core 3.X](https://dotnet.microsoft.com/download/dotnet-core) and the [QDK](https://docs.microsoft.com/en-us/quantum/quickstarts/) (Quantum development kit from Microsoft) installed.
- Inside the root folder of this project execute the project with `dotnet run`, or open the solution in visual studio and run it from there.

#NOTE:
i have cut out alot of the extra code, from Vincent and from the Quantum Kata on Satisfiability Problems -- to show only code required to solve the challenge for 3 people, to make learning this easier
