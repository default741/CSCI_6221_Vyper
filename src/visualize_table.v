module visualize_table

pub fn find_max_length(data [][]string) []int {
    /*
    Finds the maximum length of each column in the table.

    Args:
        data ([][]string): Input Array.

    Returns:
        A list of integers representing the maximum length of each column.
    */

    // Initialize an empty list to store the maximum length of each column
    mut max_list := []int{}

    // Initialize variables to keep track of the maximum and current length
    mut max_length := 0
    mut current_length := 0

    // Loop through each column in the first row of the table
    for total in 0..data[0].len {
        // Loop through each row in the table
        for list in 0..data.len {
            // Get the length of the current cell in the column
            current_length = data[list][total].str().len

            // Update max_length if the current cell's length is greater
            if current_length > max_length {
                max_length = current_length
            }
        }

        // Add the maximum length of the current column to max_list
        max_list << max_length
    }

    // Return the list of maximum lengths for each column
    return max_list
}


pub fn print_table(max_list []int) {
    /*
    Prints the border of a table.

    Args:
        max_list ([]int): A list of integers representing the maximum length of each column.
    */

    // Print the opening '+' of the border
    print('+')

    // Loop through each column's maximum length in max_list
    for i in 0..max_list.len {
        // Print '-' characters to create the horizontal border
        for _ in 0..max_list[i] + 2 {
            print('-')
        }

        // Print the closing '+' of the border
        print('+')
    }

    // Move to the next line after printing the border
    println('')
}

pub fn print_headers(data [][]string, max_list []int) {
    /*
    Prints the headers of a table.

    Args:
        data ([][]string): Input table as a 2D array of strings.
        max_list ([]int): A list of integers representing the maximum length of each column.
    */

    // Print the left border of the table
    print("| ")

    // Loop through each column in the first row of the table
    for idx in 0..data[0].len {
        // Align the header content based on the maximum length of the column
        for _ in 0..max_list[idx] - data[0][idx].str().len {
            print(' ')
        }

        // Print the content of the header cell
        print(data[0][idx])

        // Add padding and separator between header cells
        if idx == data[0].len - 1 {
            // Last column in the header, close with a right border
            print(" |")
        } else {
            // Not the last column, add a separator
            print(" | ")
        }
    }

    // Move to the next line after printing the header
    println('')
}


pub fn display(data [][]string, rows_start int, rows_end int) {
    /*
	Function to display specified rows of a table in the terminal

	Args:
		- data ([][]string): Input table as a 2D array of strings.
		- rows_start (int): The starting index of the rows to display.
		- rows_end (int): The ending index of the rows to display.
    */

    // Find the maximum length of each column in the table
    mut max_list := []int{}
    max_list = find_max_length(data)

    // Print the top border of the table
    print_table(max_list)

    // Print the headers of the table
    print_headers(data, max_list)

    // Print the ending border for the header
    print_table(max_list)

    // Loop through the specified rows and print each row
    for rows in rows_start..rows_end + 1 {
        if rows != 0 {
            // Print the left border of the table
            print("| ")

            // Loop through each column in the current row
            for idx in 0..data[rows].len {
                // Align the content based on the maximum length of the column
                for _ in 0..max_list[idx] - data[rows][idx].str().len {
                    print(' ')
                }

                // Print the content of the cell
                print(data[rows][idx])

                // Add padding and separator between cells
                if idx == data[rows].len {
                    print(" |")
                } else {
                    print(" | ")
                }
            }

            // Move to the next line after printing a row
            println('')
        }
    }

    // Print the bottom border of the table
    print_table(max_list)
    println('')
}