package com.marcopolo.service.dto;

import java.util.ArrayList;

/**
 * @author maggarwal
 * Stores the list of products
 *
 */
public class ProductsResponse {
	public ArrayList<Product> products = new ArrayList<Product>();
	
	public ArrayList<Product> getProducts() {
		return products;
	}

	public void setProducts(ArrayList<Product> products) {
		this.products = products;
	}

	public void addProduct(Product product) {
		products.add(product);
	}
}
