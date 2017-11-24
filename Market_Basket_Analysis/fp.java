

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.regex.Matcher;
import java.util.regex.Pattern;



public class fp {
	Node root;
	int minSupport = 10;
	private Map<List<String>, Integer> mapOfFrequent = new HashMap<List<String>, Integer>();
	
	public void fpGrowth(List<List<String>> transactions){
		
		HashMap<String, Integer> countOfItem = count(transactions);
		
		
		for(List<String> transaction: transactions){
			Collections.sort(transaction, new Comparator<String>() {
				@Override
				public int compare(String o1, String o2) {
					// TODO Auto-generated method stub
					if(countOfItem.get(o1)>countOfItem.get(o2)) {
						return -1;
					}
					else if(countOfItem.get(o1)<countOfItem.get(o2)) {
						return 1;
					}
						return 0;
						
				}
			});
		}
		
		
		FPGrowth(transactions, null);
	}
	
	public void FPGrowth(List<List<String>> transactions, List<String> postModel){
		Map<String, Integer> itemCount = count(transactions);
		Map<String, Node> headerTable = new HashMap<>();
		
		
		for(Entry<String, Integer> entry:itemCount.entrySet()){
			String itemName = entry.getKey();
			Integer count = entry.getValue();
			
			
			if(count>=this.minSupport){
				Node node = new Node(itemName);
				node.support = count;
				headerTable.put(itemName, node);
			}
		}
		
		Node root = buildingTree(transactions, itemCount, headerTable);
		
		if(root==null) {
			return;
		}

		if(root.child==null || root.child.size()==0) {
			return;
		}
		
		
		if(checkSingleBranch(root)){
			ArrayList<Node> path = new ArrayList<>();
			Node current = root;
			while(current.child!=null && current.child.size()>0){
				String childName = current.child.keySet().iterator().next();
				current = current.child.get(childName);
				path.add(current);
			}
			
			List<List<Node>> combinations = new ArrayList<>();
			getCombinations(path, combinations);
			
			for(List<Node> combine : combinations){
				int support = 0;
				List<String> rule = new ArrayList<>();
				for(Node node : combine){
					rule.add(node.nameOfItem);
					support = node.support;
				}
				if(postModel!=null){
					rule.addAll(postModel);
				}
				
				mapOfFrequent.put(rule, support);
			}
			
			return;
		}
		
		for(Node header : headerTable.values()){
			
			List<String> rule = new ArrayList<>();
			rule.add(header.nameOfItem);
			
			if (postModel != null) {
                rule.addAll(postModel);
            }
			
			mapOfFrequent.put(rule, header.support);
			
			List<String> newPostPattern = new ArrayList<>();
			newPostPattern.add(header.nameOfItem);
            if (postModel != null) {
                newPostPattern.addAll(postModel);
            }
            
            
            List<List<String>> newCondPattBase = new LinkedList<List<String>>();
            Node nextNode = header;
			while((nextNode = nextNode.next)!=null){
				int leaf_supp = nextNode.support;
				
			
				LinkedList<String> path = new LinkedList<>();
				Node parent = nextNode;
				while(!(parent = parent.parent).nameOfItem.equals("ROOT")){
					path.push(parent.nameOfItem);
				}
				if(path.size()==0)continue;
				
				while(leaf_supp-- >0){
					newCondPattBase.add(path);
				}
			}
			FPGrowth(newCondPattBase, newPostPattern);
		}
	}
	

	private void getCombinations(ArrayList<Node> path, List<List<Node>> combinations){
		if(path==null || path.size()==0)return;
		int length = path.size();
		for(int i = 1;i<Math.pow(2, length);i++){
			String bm = Integer.toBinaryString(i);
			List<Node> combine = new ArrayList<>();
			for(int j = 0;j<bm.length();j++){
				if(bm.charAt(j)=='1'){
					combine.add(path.get(length-bm.length()+j));
				}
			}
			combinations.add(combine);
		}
	}
	
	
	private Node buildingTree(List<List<String>> transactions, final Map<String, Integer> countOfItem, final Map<String, Node> headerTable){
		Node root = new Node("ROOT");
		root.parent = null;
		
		for(List<String> transaction : transactions){
			Node prev = root;
			HashMap<String, Node> children = prev.child;
			
			for(String itemName:transaction){
				
				if(!headerTable.containsKey(itemName))continue;
				
				Node temp;
				if(children.containsKey(itemName)){
					children.get(itemName).support++;
					temp = children.get(itemName);
				}
				else{
					temp = new Node(itemName);
					temp.parent = prev;
					children.put(itemName, temp);
					
					
					Node header = headerTable.get(itemName);
					if(header!=null){
						header.attach(temp);
					}
				}
				prev = temp;
				children = temp.child;
			}
		}
		
		return root;
		
	}
	
	 private boolean checkSingleBranch(Node root) {
	        boolean verdict = true;
	        while (root.child != null && root.child.size()>0) {
	            if (root.child.size() > 1) {
	                verdict = false;
	                break;
	            }
	            String childName = root.child.keySet().iterator().next();
	            root = root.child.get(childName);
	        }
	        return verdict;
	    }
	

	
	private HashMap<String, Integer> count(List<List<String>> transactions){
		HashMap<String, Integer> countOfItem = new HashMap<String, Integer>();
		for(List<String> transaction: transactions){
			for(String item: transaction){
				if(countOfItem.containsKey(item)){
					int count = countOfItem.get(item);
					countOfItem.put(item, ++count);
				}
				else{
					countOfItem.put(item, 1);
				}
			}
		}
		
		return countOfItem;
	}
	

	private List<List<String>> loadTransactions(String filename) throws IOException{
		
		BufferedReader br = new BufferedReader(new FileReader(new File(filename)));
		List<List<String>> transactions = new ArrayList<>();
		
		Pattern p = Pattern.compile("gain=\\w*|loss=\\w*");
		
		String nextLine;
		while((nextLine = br.readLine())!=null){
			Matcher match = p.matcher(nextLine);
			
			nextLine = match.replaceAll("");
			nextLine = nextLine.replaceAll("( )+", " "); 
			
			String[] items = nextLine.split(" ");
			
			transactions.add(new ArrayList<String>(Arrays.asList(items)));
		}
		br.close();
		
		return transactions;
	}
	
	private void showOP(int minLength){
		for(Entry<List<String>, Integer> entry : this.mapOfFrequent.entrySet()){
			List<String> rule = entry.getKey();
			if(rule.size()<minLength)continue;
			Integer support = entry.getValue();
			System.out.println(Arrays.toString(rule.toArray())+"\t\t"+"-->"+support);
		}
	}
	
	

	
	public static void main(String[] args){
		String infile = "Market_Basket_Optimisation.csv";
		
		double t = System.currentTimeMillis();
		
		fp model = new fp();
		try {
		
		
		
		List<List<String>> transactions = model.loadTransactions(infile);
		model.fpGrowth(transactions);
		}
		catch (Exception e) {
		
		}
		
		
		
		model.showOP(2);
		
		double timeTaken = System.currentTimeMillis() - t;
		
		System.out.println("Time Taken: " + timeTaken + "ms");
	}
}

