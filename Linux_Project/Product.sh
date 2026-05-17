#!/bin/bash

FILE="products.txt"
USER_FILE="users.txt"

touch "$FILE"
touch "$USER_FILE"

# ---------------- DEFAULT USER ----------------
if [ ! -s "$USER_FILE" ]; then
    echo "Asif,4590120" > "$USER_FILE"
fi

# ---------------- LOGIN SYSTEM ----------------
login() {
    attempts=3

    while [ $attempts -gt 0 ]; do
        clear

        echo "================================================="
        echo "|                                               |"
        echo "|          PRODUCT MANAGEMENT SYSTEM            |"
        echo "|                                               |"
        echo "|                 LOGIN PANEL                   |"
        echo "|                                               |"
        echo "================================================="
        echo ""

        read -p "  Username: " username
        read -s -p "  Password: " password
        echo ""
        echo ""

        if grep -q "^$username,$password$" "$USER_FILE"; then
            echo "  ✅ Login Successful!"
            sleep 1
            return
        else
            echo "  ❌ Invalid Username or Password!"
            attempts=$((attempts-1))
            echo "  Attempts Left: $attempts"
            sleep 1
        fi
    done

    echo ""
    echo "Too many failed attempts!"
    exit
}

# ---------------- ADD PRODUCT ----------------
add_product() {

    echo ""
    echo "============= ADD PRODUCT ============="

    read -p "Enter Product ID: " id

    if grep -q "^$id," "$FILE"; then
        echo "❌ Product ID already exists!"
        return
    fi

    read -p "Enter Product Name: " name
    read -p "Enter Category: " category
    read -p "Enter Supplier Name: " supplier
    read -p "Enter Quantity: " qty

    echo ""
    echo "Choose Unit:"
    echo "1. pcs"
    echo "2. kg"
    echo "3. ltr"
    read -p "Enter choice: " choice

    case $choice in
        1) unit="pcs" ;;
        2) unit="kg" ;;
        3) unit="ltr" ;;
        *) unit="pcs" ;;
    esac

    read -p "Enter Price (per $unit): " price
    read -p "Enter Start Date (DD-MM-YYYY): " sdate
    read -p "Enter Expire Date (DD-MM-YYYY): " edate

    echo "$id,$name,$category,$supplier,$qty,$unit,$price,$sdate,$edate" >> "$FILE"

    echo ""
    echo "✅ Product Added Successfully!"
}

# ---------------- VIEW PRODUCTS ----------------
view_products() {

    if [ ! -s "$FILE" ]; then
        echo "No products found!"
        return
    fi

    categories=$(cut -d, -f3 "$FILE" | sort | uniq)

    for cat in $categories
    do
        echo ""
        echo "==================== CATEGORY: $cat ===================="

        printf "| %-5s | %-22s | %-15s | %-10s | %-18s | %-12s | %-12s |\n" \
        "ID" "Name" "Supplier" "Qty" "Price(per unit)" "Start" "Expire"

        echo "---------------------------------------------------------------------------------------------------------------"

        grep ",$cat," "$FILE" | while IFS=, read -r id name category supplier qty unit price sdate edate
        do
            # Keep table aligned
            name=$(echo "$name" | cut -c1-22)
            supplier=$(echo "$supplier" | cut -c1-15)

            printf "| %-5s | %-22s | %-15s | %-10s | %-18s | %-12s | %-12s |\n" \
            "$id" "$name" "$supplier" "$qty $unit" "$price/$unit" "$sdate" "$edate"
        done

        echo "--------------------------------------------------------------------------------------------------------------"
    done
}

# ---------------- SEARCH PRODUCT ----------------
search_product() {

    echo ""
    read -p "Enter Product ID to Search: " id

    result=$(grep "^$id," "$FILE")

    if [ -n "$result" ]; then

        echo ""
        echo "============= PRODUCT DETAILS ============="

        echo "$result" | awk -F, '{
            printf "Product ID      : %s\n",$1
            printf "Product Name    : %s\n",$2
            printf "Category        : %s\n",$3
            printf "Supplier        : %s\n",$4
            printf "Quantity        : %s %s\n",$5,$6
            printf "Price           : %s per %s\n",$7,$6
            printf "Start Date      : %s\n",$8
            printf "Expire Date     : %s\n",$9
        }'

    else
        echo "❌ Product not found!"
    fi
}

# ---------------- UPDATE PRODUCT ----------------
update_product() {

    echo ""
    read -p "Enter Product ID to Update: " id

    if grep -q "^$id," "$FILE"; then

        read -p "Enter Product Name: " name
        read -p "Enter Category: " category
        read -p "Enter Supplier Name: " supplier
        read -p "Enter Quantity: " qty

        echo ""
        echo "Choose Unit:"
        echo "1. pcs"
        echo "2. kg"
        echo "3. ltr"
        read -p "Enter choice: " choice

        case $choice in
            1) unit="pcs" ;;
            2) unit="kg" ;;
            3) unit="ltr" ;;
            *) unit="pcs" ;;
        esac

        read -p "Enter Price (per $unit): " price
        read -p "Enter Start Date (DD-MM-YYYY): " sdate
        read -p "Enter Expire Date (DD-MM-YYYY): " edate

        temp=$(mktemp)

        grep -v "^$id," "$FILE" > "$temp"

        echo "$id,$name,$category,$supplier,$qty,$unit,$price,$sdate,$edate" >> "$temp"

        mv "$temp" "$FILE"

        echo ""
        echo "✅ Product Updated Successfully!"

    else
        echo "❌ Product not found!"
    fi
}

# ---------------- DELETE PRODUCT ----------------
delete_product() {

    echo ""
    read -p "Enter Product ID to Delete: " id

    if grep -q "^$id," "$FILE"; then

        temp=$(mktemp)

        grep -v "^$id," "$FILE" > "$temp"

        mv "$temp" "$FILE"

        echo ""
        echo "✅ Product Deleted Successfully!"

    else
        echo "❌ Product not found!"
    fi
}

# ---------------- MAIN PROGRAM ----------------
login

while true
do
    echo ""
    echo "================================================="
    echo "|         PRODUCT MANAGEMENT SYSTEM              |"
    echo "================================================="
    echo "| 1. Add Product                                 |"
    echo "| 2. View Products                               |"
    echo "| 3. Search Product                              |"
    echo "| 4. Update Product                              |"
    echo "| 5. Delete Product                              |"
    echo "| 6. Exit                                        |"
    echo "================================================="

    read -p "Choose an Option: " choice

    case $choice in

        1) add_product ;;

        2) view_products ;;

        3) search_product ;;

        4) update_product ;;

        5) delete_product ;;

        6)
            echo ""
            echo "Thank You for Using the System!"
            exit
            ;;

        *)
            echo "❌ Invalid Option!"
            ;;

    esac

done
