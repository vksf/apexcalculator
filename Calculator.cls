public without sharing class Calculator {
	
    public class NullValueNotAllowedException extends Exception {}
    public class StackOverflowException extends Exception {}
    public class StackUnderflowException extends Exception {}
    public class FormulaErrorException extends Exception {}


	public without sharing class DoubleStack {

	    private Integer MAX_STACK_DEPTH = 1000;	    
	    private List<Double> stack;

	    public DoubleStack(){
	        stack = new List<Double>();
	    }
	    	    	    	    
	    public void push(Double s){ 
	        if (s == null) { throw new NullValueNotAllowedException(); }
	        if (this.isFull()) { throw new StackOverflowException(); }
	        stack.add(s); 
	    }
	    
	    public Double pop() { 
	        if (this.isEmpty()) { throw new StackUnderflowException(); }
	        return stack.remove( lastItemIndex );
	    }
	    
	    public Double peak() { 
	        if (this.isEmpty()) { throw new StackUnderflowException(); }
	        return stack.get( lastItemIndex );
	    }

	    public Boolean isEmpty() {return stack.isEmpty();}
	    public Boolean isFull() {return MAX_STACK_DEPTH == stack.size();}
	    private Integer lastItemIndex {get{return stack.size() - 1;}}	    
	    	    
	}


	public without sharing class StringStack {			
			
	    private Integer MAX_STACK_DEPTH = 1000;	    
	    private List<String> stack;

	    public StringStack(){
	        stack = new List<String>();
	    }


	    public void push(String s){ 
	        if (s == null) { throw new NullValueNotAllowedException(); }
	        if (this.isFull()) { throw new StackOverflowException(); }
	        stack.add(s); 
	    }
	    
	    public String pop() { 
	        if (this.isEmpty()) { throw new StackUnderflowException(); }
	        return stack.remove( lastItemIndex );
	    }
	    
	    public String peak() { 
	        if (this.isEmpty()) { throw new StackUnderflowException(); }
	        return stack.get( lastItemIndex );
	    }	    	    

	    public Boolean isEmpty() {return stack.isEmpty();}
	    public Boolean isFull() {return MAX_STACK_DEPTH == stack.size();}	    	    
	    private Integer lastItemIndex {get{return stack.size() - 1;}}

	}


    private static Map<String, Integer> operatorPrioritetMap = new Map<String, Integer> {
        '!' => 15, 
        '*' => 13, 
        '/' => 13, 
        '+' => 12, 
        '-' => 12, 
        '>=' => 10, 
        '<=' => 10, 
        '<' => 10, 
        '>' => 10, 
        '==' => 9, 
        '!=' => 9, 
        '&&' => 5, 
        '||' => 4
    };
    
    private static Boolean isSpace (String c){ return c == ' '; }    
    private static Boolean isOperator (String c) { 
        return operatorPrioritetMap.containsKey(c);
    }   
    
    private static Integer getPriority (String op) { 
        Integer result = operatorPrioritetMap.get(op);
        if (result == null) result = -1;
        return result; 
    } 
    
    private static void processOperator (StringStack st, String op){
        if (op == '!') {
            Boolean r = Boolean.valueOf(st.peak()); st.pop();
            st.push (String.valueOf(!r));           
        } else if (op == '&&' || op == '||') {
        	if (st.peak() != 'false' && st.peak() != 'true'){
        		throw new FormulaErrorException();
        	}
            Boolean r = Boolean.valueOf(st.peak()); st.pop();
            Boolean l = Boolean.valueOf(st.peak()); st.pop();
            if (op == '&&') st.push (String.valueOf(l && r));           
            if (op == '||') st.push (String.valueOf(l || r));           
        } else {
            double r = Double.valueOf(st.peak()); st.pop();
            double l = Double.valueOf(st.peak()); st.pop();
            if (op == '+')  st.push (String.valueOf(l + r)); 
            if (op == '-')  st.push (String.valueOf(l - r));            
            if (op == '*')  st.push (String.valueOf(l * r));
            if (op == '/')  if (r!=0) st.push (String.valueOf(l / r)); else st.push ('0'); //oops! division by zero!
            if (op == '<')  st.push(String.valueOf(l < r)); 
            if (op == '>')  st.push(String.valueOf(l > r)); 
            if (op == '<=')  st.push(String.valueOf(l <= r)); 
            if (op == '>=')  st.push(String.valueOf(l >= r)); 
            if (op == '==')  st.push(String.valueOf(l == r)); 
            if (op == '!=')  st.push(String.valueOf(l != r)); 
        }        
    }
 
    public static String calc (String formula){
        if (String.isEmpty(formula)) return '0'; // formula mot defined
        formula = '(' + formula.toLowerCase().normalizeSpace() + ')';
        if (formula.replace(' ','').contains('(|') ||
        	formula.replace(' ','').contains('(&') ||
        	formula.replace(' ','').contains('|)') ||
        	formula.replace(' ','').contains('&)')
        	) throw new FormulaErrorException();
        System.debug(formula);
        
        StringStack st = new StringStack();
        StringStack op = new StringStack();
        String letter = ''; 

        for (Integer i=0; i<formula.length(); i++){
            letter = formula.substring(i,i+1);
            System.debug(letter);
            if (isSpace(letter)) continue;
            if (letter == '(') {
                op.push ('(');
            } else if (letter == ')') {
                while (op.peak() != '('){
                    processOperator (st, op.peak()); op.pop();
                }
                op.pop();
            } else if (letter.containsAny('+-*/<>=|&!')) {
                String sub = formula.substring(i);
                String operation;
                if (sub.startsWithIgnoreCase('&&')) {
                    operation = '&&'; i++;                  
                } else if (sub.startsWithIgnoreCase('||')) {
                    operation = '||'; i++;                  
                } else if (sub.startsWithIgnoreCase('==')) {
                    operation = '=='; i++;                  
                } else if (sub.startsWithIgnoreCase('!=')) {
                    operation = '!='; i++;                  
                } else if (sub.startsWithIgnoreCase('>=')) {
                    operation = '>='; i++;                  
                } else if (sub.startsWithIgnoreCase('<=')) {
                    operation = '<='; i++;                  
                } else if (isOperator(letter)) {
                    operation = letter;                                     
                }
                
                if (!String.isEmpty(operation)) {               
                    while (!op.isempty() && getPriority(op.peak()) >= getPriority(operation)){
                        processOperator (st, op.peak());  op.pop();
                    }
                    op.push(operation);
                    continue;
                }
            } else if ((letter == '.') || letter.isNumeric()) {
                string operand = '';
                while ((letter == '.') || letter.isNumeric()){
                   operand += letter; i++;
                   letter = formula.substring(i,i+1);
                }--i;
                if (operand != '') st.push(operand);
            } else if (letter == 't' || letter == 'f') {
                String sub = formula.substring(i);
                string operand = '';
                if (sub.startsWithIgnoreCase('true')) {
                    operand = 'true';
                    i = i + 3;
                } else if (sub.startsWithIgnoreCase('false')) {
                    operand = 'false';
                    i = i + 4;
                }
                
                if (operand != '') st.push(operand);
            }
            
            else {
                throw new FormulaErrorException();
                return '0'; //error in formula! 
            }
        }
        while (!op.isempty()){
            processOperator (st, op.peak());  op.pop();
        }
        
        String stresult = st.pop(); 
        
        if(st.isEmpty()){
        	return stresult;
        }else{
        	throw new FormulaErrorException();
        	return '0';
        }
    }
}