/**
 * 
 */
package com.marcopolo.service.dto;

import java.math.BigDecimal;

/**
 * @author maggarwal
 * Class to store different products for in app purchase
 *
 */
public class Product {
	private String productId, appleProductId, description;
	private int imagesLeft;
	private BigDecimal price;

	public String getProductId() {
		return productId;
	}
	public void setProductId(String productId) {
		this.productId = productId;
	}
	public String getAppleProductId() {
		return appleProductId;
	}
	public void setAppleProductId(String appleProductId) {
		this.appleProductId = appleProductId;
	}
	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}
	public int getImagesLeft() {
		return imagesLeft;
	}
	public void setImagesLeft(int imagesLeft) {
		this.imagesLeft = imagesLeft;
	}
	public BigDecimal getPrice() {
		return price;
	}
	public void setPrice(BigDecimal price) {
		this.price = price;
	}

}
