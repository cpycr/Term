use v5.38;
use experimentals;
use Object::Pad;

class MakeChars {
	field $pp = {};

	method makeChars($program) {
		my @chars = split("", $program);
		$pp->{"chars"} = \@chars;
		$pp->{"charsLength"} = $#chars;
	}

	method programLength() {
		return $pp->{"charsLength"};
	}

	method getChar() {
		my @chars = @{$pp->{"chars"}};
		my $char = shift(@chars);
		$pp->{"chars"} = \@chars;
		$pp->{"charsLength"} = $#chars;
		return $char;
	}

	method nextChar() {
		my @chars = @{$pp->{"chars"}};
		return $chars[0];
	}

	method putChar($char) {
		my @chars = @{$pp->{"chars"}};
		unshift(@chars, $char);
		$pp->{"chars"} = \@chars;
		$pp->{"charsLength"} = $#chars;
	}

}

class CharGroups {
	method isSpaceNewLine($char) {
		my @spaceNewLline = (" ", "\n", "\t", "\r");
		my %hash = map {$_ => 1} @spaceNewLline;
		if(exists($hash{$char})) {return 1;}
		return 0;
	}

	method isDigit($char) {
		my @digits = ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9");
		foreach my $digit (@digits) {
			if ( $char eq $digit ) {
				return 1;
			}
		}
		return 0;
	}

	method isAlpha($char) {
		my @alpha = ();

		for my $char ( 'a' ... 'z' ) {
			push @alpha, $char;
		}
		for my $char ( 'A' ... 'Z' ) {
			push @alpha, $char;
		}
		push @alpha, "_";

		my %hash = map {$_ => 1} @alpha;
		if(exists($hash{$char})) {return 1;}
		return 0;
	}

	method isQuote($char) {
		if ( $char eq '"' ) {
			return 1;
		}
		else {
			return 0;
		}
	}

	method isSpecialCharachter($char) {
		my @specialCharachters = ( "{", "}", "[", "]", ",", ":", "(", ")", ";", "=", "." );
		
		my %hash = map {$_ => 1} @specialCharachters;
		if(exists($hash{$char})) {return 1;}
		return 0;
	}

	method isOperator($char) {
		my @operators = ( "+", "-", "|", "*", "/", ">", "<", "!", "&", "%" );
		
		my %hash = map {$_ => 1} @operators;
		if(exists($hash{$char})) {return 1;}
		return 0;
	}

}

class Lexer {
	method lexer($program) {
		my $makeChars = MakeChars->new();
		my $CharGroups = CharGroups->new();

		my @tokens;
		$makeChars->makeChars($program);

		my $counter = 0;
		my $programLength = $makeChars->programLength();


		while($counter <= $programLength) {
			my $currentChar = $makeChars->getChar();
			$counter++;

			if($CharGroups->isSpaceNewLine($currentChar)) { next; }
			if($currentChar eq "=" && $makeChars->nextChar() eq "=" ) {
				$makeChars->getChar();
				$counter++;

				my $token = {"type" => "Equals", "value" => "=="};
				push(@tokens, $token);
				next;
			}


			if ( $CharGroups->isOperator($currentChar) ) {
				if ( $currentChar eq "&" ) {
					my $nextChar = $makeChars->nextChar();
					if ( $nextChar eq "&" ) {
						$makeChars->getChar();
						$counter++;

						my $token = { "type" => "Operator", "value" => "&&" };
						push( @tokens, $token );
						next;
					}
				}
			}

			if ( $CharGroups->isOperator($currentChar) ) {
				if ( $currentChar eq "|" ) {
					my $nextChar = $makeChars->nextChar();
					if ( $nextChar eq "|" ) {
						$makeChars->getChar();
						$counter++;

						my $token = { "type" => "Operator", "value" => "||" };
						push( @tokens, $token );
						next;
					}
				}
			}

			if ( $CharGroups->isOperator($currentChar) ) {
				my $token = { "type" => "Operator", "value" => $currentChar };
				push( @tokens, $token );
				next;
			}

			if ( $CharGroups->isQuote($currentChar) ) {
				my $string    = "";
				my $delimiter = $currentChar;

				$currentChar = $makeChars->getChar();
				$counter++;

				while ( $currentChar ne $delimiter ) {
					$string .= $currentChar;
					$currentChar = $makeChars->getChar();
					$counter++;
				}

				my $token = { "type" => "String", "value" => $string };
				push( @tokens, $token );
				next;
			}

			if ( $CharGroups->isSpecialCharachter($currentChar) ) {
				my $token =
					{ "type" => "SpecialCharachter", "value" => $currentChar };
				push( @tokens, $token );
				next;
			}
			if ( $CharGroups->isAlpha($currentChar) ) {
					my $symbol = "";
					$symbol .= $currentChar;

					$currentChar = $makeChars->getChar();
					$counter++;

					while ( $CharGroups->isAlpha($currentChar) ) {
						$symbol .= $currentChar;
						$currentChar = $makeChars->getChar();
						$counter++;
					}

					$makeChars->putChar($currentChar);
					$counter = $counter - 1;

					my $token = { "type" => "Symbol", "value" => $symbol };
					push( @tokens, $token );
					next;
				}

				if ( $CharGroups->isDigit($currentChar) ) {
					my $number = "";
					$number .= $currentChar;

					$currentChar = $makeChars->getChar();
					$counter++;

					while ( $CharGroups->isDigit($currentChar) || $currentChar eq "." ) {
						$number .= $currentChar;
						$currentChar = $makeChars->getChar();
						$counter++;
					}

					$makeChars->putChar($currentChar);
					$counter = $counter - 1;

					my $token = { "type" => "Number", "value" => $number };
					push( @tokens, $token );

					next;
				}
		}

		return @tokens;
	}
}

class ParseHelpers {
	field $pp = {};

    method makeTokens(@tokens) {
        $pp->{"tokens"} = \@tokens;
        $pp->{"tokensLength"} = $#tokens;
    }

    method tokensLength() {
        return $pp->{"tokensLength"};
    }

    method getToken() {
        my @tokens = @{$pp->{"tokens"}};
        my $currentToken = shift(@tokens);
        $pp->{"tokens"} = \@tokens;
        $pp->{"tokensLength"} = $#tokens;
        return $currentToken;
    }

    method nextToken() {
        my @tokens = @{$pp->{"tokens"}};
        return $tokens[0];
    }

    method putToken($token) {
        my @tokens = @{ $pp->{"tokens"}};
        unshift(@tokens, $token);
        $pp->{"tokens"} = \@tokens;
        $pp->{"tokensLength"} = $#tokens;
    }
}


class FunctionBody {
    field $tokens :param;
    field $pp = {};

    method makeBlockTokens(@tokens) {
        $pp->{"blockTokens"} = \@tokens;
        $pp->{"blockTokensLength"} = $#tokens;
    }

    method blockTokensLength() {return $pp->{"blockTokensLength"};}

    method getBlockToken() {
        my @tokens = @{$pp->{"blockTokens"}};
        my $currentToken = shift(@tokens);
        $pp->{"blockTokens"} = \@tokens;
        $pp->{"blockTokensLength"} = $#tokens;
        return $currentToken;
    }

    method nextBlockToken() {
        my @tokens = @{$pp->{"blockTokens"}};
        return $tokens[0];
    }

    method putBlockToken($token) {
        my @tokens = @{$pp->{"blockTokens"}};
        unshift(@tokens, $token);
        $pp->{"blockTokens"} = \@tokens;
        $pp->{"blockTokensLength"} = $#tokens;
    }
	
    method functionBody() {
        use Data::Printer;
        $self->makeBlockTokens(@{$tokens});
        my $blockTokensLength = $self->blockTokensLength();
        my $counter = 0;
        
        while($counter <= $blockTokensLength) {
            my $token = $self->getBlockToken(); $counter++;
            if($token->{"value"} eq "if") {
                my $token=$self->getBlockToken();$counter++;
                my @expr;
                my $exprToken = {"value" => "_"};
                until($exprToken->{"value"} eq ")") {
                    $exprToken = $self->getBlockToken(); $counter++;
                    if($exprToken->{"value"} ne ")") {
                        push(@expr, $exprToken->{"value"});
                    }
                }
                my @IfExpr = @expr;
                my @ifBody = ();
                
				my $ifBeginToken = $self->getBlockToken();$counter++;
                # .....
				my $ifBraceCounter = 1;
				while($ifBraceCounter > 0) {
                     my $tok = $self->getBlockToken();$counter++;
					 print($tok->{"value"}); exit();
					 if( $tok->{"value"} eq "{" ) {
                         $ifBraceCounter++;
                     } elsif( $tok->{"value"} eq "}" ) {
                         $ifBraceCounter--;
                     } elsif($ifBraceCounter > 0) {
                         push(@ifBody, $tok);
                     } else {$ifBraceCounter--;} #$ifBraceCounter--;
                }

				use Data::Printer;
				p(@ifBody);
            }

            if($token->{"value"} eq "while") {
                my $token = $self->getBlockToken();$counter++;
                my @expr;
                my $exprToken = {"value" => "_"};
                until($exprToken->{"value"} eq ")") {
                    $exprToken = $self->getBlockToken();$counter++;
                    if($exprToken->{"value"} ne ")") {
                        push(@expr, $exprToken->{"value"});
                    }
                }
                my @WhileExpr = @expr;
                my @whileBody = ();

                my $whileBeginToken = $self->getBlockToken();$counter++;
                my $whileBraceCounter = 0;
                if($whileBeginToken->{"value"} eq "{") { 	## .......
                    $whileBraceCounter++;
                    my $tok = $self->getBlockToken();$counter++;
                    if($tok->{"value"} eq "{") {
                        $whileBraceCounter++;
                    } elsif($tok->{"value"} eq "}") {
                        $whileBraceCounter--;
                    } elsif($whileBraceCounter > 0) {
                        push(@whileBody, $tok);
                    } else {} # end this loop
                }

                   
            }
           
            #my @statement = ();	
        }
        return {"body" => "Functoin Body"};
    }    
}


class Main {
	use Data::Printer;
	field $parseTree = {};

	method main($program) {
		my $parseHelpers = ParseHelpers->new();
		my $lexer = Lexer->new();

		my @tokens = $lexer->lexer($program);
		$parseHelpers->makeTokens(@tokens);
		my $tokensLength = $parseHelpers->tokensLength();
		my $counter = 0;
		my $function;

		while($counter <= $tokensLength) {
			my $token = $parseHelpers->getToken(); $counter++;
			if($token->{"value"} eq 'func') {
				my $token = $parseHelpers->getToken(); $counter++;
				
				my $functionName = $token->{"value"};
				
				$parseHelpers->getToken();$counter++;
				my @args;
				my $argToken = {"value" => "_"};
				until( $argToken->{"value"} eq ")") {
					$argToken = $parseHelpers->getToken();
					$counter++;
					if($argToken->{"value"} ne ")"
						&& $argToken->{"value"} ne ",") {
						push(@args, $argToken->{"value"});
					}
				}
				
				my @functionArgs = @args;               
				my @functionBody = ();

				my $bodyBeginToken = $parseHelpers->getToken();$counter++;
				if($bodyBeginToken->{"value"} eq "{") {
					my $untilCounter = 0;
					until($untilCounter == 1) {
						my $bodyToken = $parseHelpers->getToken();$counter++;
						my $bodyNextToken = $parseHelpers->nextToken();
						if($bodyToken->{"value"} eq "}"
							|| ($bodyNextToken->{"value"} eq "func")
								|| $counter == $tokensLength + 1) {
									$untilCounter = 1;
								}
						else {
							push(@functionBody, $bodyToken);
						}
					}
				}
				
				my $functionBodyObject = FunctionBody->new(tokens =>\@functionBody);
				$function = {
					"functionName" => $functionName,
					"functionArgs" => \@functionArgs,
					"functionBody" => $functionBodyObject->functionBody()
				};
				$parseTree->{$functionName} = $function;  
				$function = {};  
			}
			# exit
		}
		p($parseTree);
	}
}

my $program ='
		func anotherPrint(arg){
			if(x > 23){
				print(arg, "\n");
			}
		}
		func main(){
			var sum = 12 + 14;
			while(sum < 23){
				print("Sum is ", sum);
			}
		}
	';

Main->new()->main($program);


