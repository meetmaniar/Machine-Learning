

import java.util.HashMap;

public class Node {
	
	int support;
	String nameOfItem;
	HashMap<String, Node> child;
	Node next; 
	Node parent;
	
	public Node(String name) {
		this.nameOfItem = name;
		this.support = 1;
		this.child =  new HashMap<String, Node>();
		this.next =null;
		this.parent = null;
	}

	@Override
	public String toString() {
		return "Node [support=" + support + ", itemName=" + nameOfItem + "]";
	}
	
	public void attach(Node t){
		Node node = this;
		while(node.next!=null){
			node = node.next;
		}
		node.next = t;
	}
}


