namespace Quantum.SecretSanta {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Convert;


    operation Oracle_SAT ( queryRegister : Qubit [] , target : Qubit ) : Unit is Adj {
//    	    Vincent Tess Uma
// Vincent     -    x(0) x(1)
// Tess       x(2)   -   x(3)
// Uma	      x(4)  x(5)  -
//  ( 0 , 1 ) ( 2 , 3 ) ( 4 , 5 ) ( 2 , 4 ) ( 0 , 5 ) ( 1 , 3 )

	    use aux = Qubit [ 6 ] {
            within {
                ApplyToEachA ( CNOT ( _ , aux [ 0 ] ) , [ queryRegister [ 0 ] , queryRegister [ 1 ] ] ); 
                ApplyToEachA ( CNOT ( _ , aux [ 1 ] ) , [ queryRegister [ 2 ] , queryRegister [ 3 ] ] ); 
                ApplyToEachA ( CNOT ( _ , aux [ 2 ] ) , [ queryRegister [ 4 ] , queryRegister [ 5 ] ] ); 
                ApplyToEachA ( CNOT ( _ , aux [ 3 ] ) , [ queryRegister [ 2 ] , queryRegister [ 4 ] ] ); 
                ApplyToEachA ( CNOT ( _ , aux [ 4 ] ) , [ queryRegister [ 0 ] , queryRegister [ 5 ] ] ); 
                ApplyToEachA ( CNOT ( _ , aux [ 5 ] ) , [ queryRegister [ 1 ] , queryRegister [ 3 ] ] ); 
            }
            apply {
                Controlled X ( aux , target );
            }
        }
    }

    operation Oracle_Converter ( markingOracle : ( ( Qubit [] , Qubit ) => Unit is Adj ) , register : Qubit [] ) : Unit is Adj {
        use target = Qubit () {
            // Put the target into the |-⟩ state and later revert the state
            within { 
                X ( target );
                H ( target ); 
            }
            // Apply the marking oracle; since the target is in the |-⟩ state,
            // flipping the target if the register satisfies the oracle condition will apply a -1 factor to the state
            apply { 
                markingOracle ( register , target );
            }
        }
    }

    operation GroversLoop ( register : Qubit [] , oracle : ( ( Qubit [] , Qubit ) => Unit is Adj ) , numIterations : Int ) : Unit {
        let phaseOracle = Oracle_Converter ( oracle , _ );
        ApplyToEach ( H , register );

        for _ in 1 .. numIterations {
            phaseOracle ( register );
            within {
                ApplyToEachA ( H , register );
                ApplyToEachA ( X , register );
            } 
            apply {
                Controlled Z ( Most ( register ) , Tail ( register ) );
            }
        }
    }

    // Main function to run the Grover search 
    operation RunGroversSearch ( N : Int , oracle : ( ( Qubit [] , Qubit ) => Unit is Adj ) ) : Bool [] {
        // Try different numbers of iterations.
        mutable answer = new Bool [ N ];
        use ( register , output ) = ( Qubit [ N ] , Qubit () ) {
            mutable correct = false;
            mutable iter = 1;
            repeat {
                Message ( $"Trying search with {iter} iterations" );
                GroversLoop ( register , oracle , iter );
                let res = MultiM ( register );
            
                oracle ( register , output );
                if ( MResetZ ( output ) == One ) {
                    set correct = true;
                    set answer = ResultArrayAsBoolArray ( res );
                }
                ResetAll ( register );
            } until ( correct or iter > 30 )  // The fail-safe to avoid going into an infinite loop
            fixup {
                set iter *= 2;
            }
            if ( not correct ) {
                fail "Failed to find an answer";
            }
        }
        Message ( $"{answer}" );
        return answer;
    }

    @EntryPoint()
    operation RunSecretSanta () : Unit {
        Message($"Simulate the Secret Santa raffle with:  Tess, Uma, and Vincent");

        let N = 6;

        let oracle = Oracle_SAT ( _ , _ );
        let result = RunGroversSearch ( N , oracle );
        PrintResults ( result );
    }

    // Outputs the result on the console to see who has picked who.
    operation PrintResults ( result : Bool [] ) : Unit {
        let names = [ "Vincent" , "Uma    " , "Tess   " ];
        mutable count = 0;
        
        for  i in 0 .. 3 {
            mutable line = "";
            for j in 0 .. 3 {
                if i == 0 {
                    if j != 0 {
                        set line += $"| {names[j - 1]}    ";
                    } else {
                        //set line += "  ";
                        set line += "         ";
                    }
                } else {
					if j == 0 {
                        set line += $" {names[i - 1]} |";
                    } else {
                        if i == j {
                            //set line += "  X  |";
                            set line += "     X      |";
                        } else {
                            if ( result [ count ] ) {
                                set line += $"    true    |";
                            } else {
                                set line += $"    false   |";
                            }
                            set count += 1;
                        }
                    }
                }
            }
            Message(line);
        }
    }
}
