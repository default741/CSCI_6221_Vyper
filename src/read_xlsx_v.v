module read_xlsx_v

import time
import szip
import strconv

struct XLSX {
  	mut:
		zp szip.Zip
}

struct Format {
	formats []string
	custom_formats map[string]string
}

fn XLSX.new(zipfile string) !XLSX {
	/*
	Opens the input zip file and saves it to the excel struct.

	Args:
		zipfile ([]f64): File Name for the zip file

	Returns:
		XLSX: XLSX Struct
	*/
	return XLSX {
		zp: szip.open(zipfile, szip.CompressionLevel.no_compression, szip.OpenMode.read_only)!
	}
}

[unsafe]
fn (mut xlsx XLSX) free() {
	/*
	Closes the zipfile

	Args:
		xlsx ([]f64): XLSX Struct
	*/
  	xlsx.zp.close()
}

fn (mut xlsx XLSX) open_xml(name string) !string {
	/*
	open_xml opens an XML entry in an XLSX file and returns its content as a string.

	Parameters:
		xlsx (XLSX): A mutable XLSX object representing the Excel file.
		name (string): The name of the XML entry to be opened in the XLSX file.

	Returns:
		string: A string containing the content of the specified XML entry.

	Error Handling:
		1. If there is an issue opening the entry or reading its content, an error is returned.

	Note:
		1. The function automatically closes the entry when it exits, ensuring proper resource management.
		2. An empty string is returned if the entry has a size of 0, possibly indicating an empty or invalid entry.
		3. The use of `unsafe` suggests potential risks, such as direct memory access during the conversion of the buffer to a string.
	*/

	xlsx.zp.open_entry(name)! // Open the specified entry in the zip archive
    defer {
        xlsx.zp.close_entry() // Ensure that the entry is closed when the function exits
    }

    size := xlsx.zp.size() // Get the size of the entry
    if size == 0 {
        return '' // If the size is 0, return an empty string
    }

    buf := xlsx.zp.read_entry()! // Read the entry into a buffer
    xml := unsafe {
        tos(buf, int(size)) // Convert the buffer to a string (unsafe operation)
    }

    return xml // Return the XML content as a string
}

fn (mut xlsx XLSX) parse_shared_strings() ![]string {
	/*
	parse_shared_strings reads and parses the shared strings from the 'xl/sharedStrings.xml' file in an XLSX document.

	Parameters:
		- xlsx: A mutable XLSX object representing the Excel file.

	Returns:
		- A dynamic array of strings containing the shared strings from the Excel file.

	Error Handling:
		- If there is an issue opening or parsing the 'xl/sharedStrings.xml' file, an error is returned.

	Note:
		- This function relies on the open_xml method to retrieve the XML content of the shared strings file.
		- The XML content is then parsed using an XMLParser, and only elements with the name 'si' are selected.
		- The text content of these 'si' elements is extracted and returned as an array of strings.
	*/

	xml := xlsx.open_xml('xl/sharedStrings.xml')! // Open the shared strings XML file
	tags := XMLParser.new(xml) // Initialize an XML parser with the XML content

	return tags.filter(it.name == 'si').map(it.text()) // Filter for 'si' elements and map them to their text content
}

fn (mut xlsx XLSX) parse_formats() !Format {
	/*
	parse_formats reads and parses the number formats from the 'xl/styles.xml' file in an XLSX document.

	Parameters:
		- xlsx: A mutable XLSX object representing the Excel file.

	Returns:
		- A Format object containing information about the number formats.

	Error Handling:
		- If there is an issue opening or parsing the 'xl/styles.xml' file, an error is returned.

	Note:
		- This function extracts number formats from both the 'xf' elements under 'cellXfs' and 'numFmt' elements.
		- The 'xf' elements are filtered to find those with the name 'xf' and parent name 'cellXfs'.
		- The 'numFmt' elements are used to build a map of custom number formats.
	*/

	xml := xlsx.open_xml('xl/styles.xml')! // Open the styles XML file
	tags := XMLParser.new(xml) // Initialize an XML parser with the XML content

	// Extract number formats from 'xf' elements under 'cellXfs'
	formats := tags.filter(it.name == 'xf' && it.parent.name == 'cellXfs').map(it.attributes['numFmtId'])

	// Initialize a map to store custom number formats
	mut custom_formats := map[string]string{}

	// Iterate over 'numFmt' elements and populate the custom_formats map
	for num_fmt in tags.filter(it.name == 'numFmt') {
		custom_formats[num_fmt.attributes['numFmtId']] = num_fmt.attributes['formatCode']
	}

	// Return a Format object containing extracted number formats
	return Format {
		formats: formats,
		custom_formats: custom_formats,
	}
}

fn r2ci(r string) !int {
	/*
	r2ci converts an Excel-style column label (e.g., 'A', 'B', 'AA') to its corresponding column index.

	Parameters:
		- r: A string representing an Excel column label.

	Returns:
		- An integer representing the corresponding column index (0-based).

	Error Handling:
		- If there is an issue parsing the input string or converting it to an integer, an error is returned.

	Note:
		- This function assumes the input column label follows the Excel column naming convention.
		- The column label is case-insensitive, and non-alphabetic characters are trimmed.
		- The conversion is based on the position of letters in the alphabet and follows a base-26 system.
	*/

	letters := r.trim('0123456789').to_lower() // Trim numeric characters and convert to lowercase
	mut sum := 0 // Initialize sum for the column index

	// Iterate over each letter in the trimmed and lowercase column label
	for letter in letters.split('') {
		num := strconv.parse_int(letter, 36, 0)! // Parse the letter as an integer in base-36
		sum = sum * 26 + int(num) - 9 // Update the sum using the base-26 conversion formula
	}

	return sum - 1 // Adjust for 0-based indexing and return the column index
}

fn (mut xlsx XLSX) parse_sheet(shared_strings []string, formats Format) ![][]string {
	/*
	parse_sheet reads and parses the data from the 'xl/worksheets/sheet1.xml' file in an XLSX document.

	Parameters:
		- xlsx: A mutable XLSX object representing the Excel file.
		- shared_strings: An array of shared strings used in the Excel file.
		- formats: A Format object containing information about number formats.

	Returns:
		- A 2D array of strings representing the parsed data from the sheet.

	Error Handling:
		- If there is an issue opening or parsing the 'xl/worksheets/sheet1.xml' file, an error is returned.

	Note:
		- This function extracts data from 'row' elements in the sheet XML file.
		- It handles various data types, including shared strings and custom number formats.
	*/

	xml := xlsx.open_xml('xl/worksheets/sheet1.xml')! // Open the sheet XML file
	tags := XMLParser.new(xml) // Initialize an XML parser with the XML content

	rows := tags.filter(it.name == 'row') // Filter for 'row' elements in the XML
	mut data := [][]string{cap: rows.len} // Initialize a 2D array to store the parsed data

	// Iterate over each 'row' element
	for row in rows {
		cols := row.children // Extract the child elements of the 'row' (representing columns)

		// Initialize an array to store values in the row
		mut values := []string{len: cols.len}

		// Iterate over each 'col' element in the row
		for col_i, col in cols {
			ci := if col_r := col.attributes['r'] { r2ci(col_r)! } else { col_i } // Determine the column index (ci)

			// Extract the text content of the 'col' element
			v := col.text()
			mut value := v

			// Check for the 't' attribute indicating a data type
			if t := col.attributes['t'] {
				match t {
					's' {
						// If the data type is 's' (shared string), use the shared string value
						value = shared_strings[strconv.parse_int(v, 10, 0)!] or { v }
					}
					'e' {
						// If the data type is 'e' (error), set the value to an empty string
						value = ''
					}
					else { }
				}
			} else if s := col.attributes['s'] {
				// If the 's' attribute is present, indicating a number format
				format_id := strconv.parse_int(s, 10, 0)!

				// Check if the format is available in the 'formats' object
				if format := formats.formats[format_id] {
					if v.len > 0 {
						// Process date formats and custom formats
						match format {
							'14', '15', '16', '17', '22', '57', '58' { // Various date formats
								t := excel_to_date(value)!
								value = t.custom_format('YYYY-MM-DD HH:mm:ss')
							}
							else {
								// Handle custom number formats
								if format in formats.custom_formats {
									format_code := formats.custom_formats[format]

									if format_code.contains('yy') {
										t := excel_to_date(value)!

										if format_code.contains('h') {
											value = t.custom_format('YYYY-MM-DD HH:mm:ss')
										} else {
											value = t.custom_format('YYYY-MM-DD')
										}
									}
								}
							}
						}
					}
				}
			}

			// Adjust array size if necessary
			if ci >= values.len {
				unsafe {
				values.grow_len(ci - values.len + 1)
				}
			}

			// Set the value in the array
			values[ci] = value
		}

		// Check if any non-empty values exist in the row and append to the data array
		if values.any(it.trim_space() != '') {
			data << values
		}
	}

	// Return the parsed data
	return data
}

fn excel_to_date(s string) !time.Time {
	/*
	excel_to_date converts an Excel date represented as a numeric value to a time.Time object.

	Parameters:
		- s: A string representing an Excel date as a numeric value.

	Returns:
		- A time.Time object representing the converted date and time.

	Error Handling:
		- If there is an issue converting the input string to a floating-point number or Unix timestamp, an error is returned.

	Note:
		- Excel represents dates as the number of days since December 30, 1899 (with fractional days as the time).
		- The function converts the Excel date to Unix timestamp (seconds since January 1, 1970).
		- The Unix timestamp is used to create a time.Time object.
	*/

	v := strconv.atof64(s)! // Convert the input string to a floating-point number
	t := time.unix(i64((v - 25569) * 24 * 3600)) // Calculate the Unix timestamp from the Excel date representation

	return t // Return the time.Time object
}

pub fn parse(xlsxfile string) ![][]string {
	/*
	parse reads and parses data from an XLSX file.

	Parameters:
		- xlsxfile: A string representing the path to the XLSX file.

	Returns:
		- A 2D array of strings representing the parsed data from the XLSX file.

	Error Handling:
		- If there is an issue initializing or parsing the XLSX file, an error is returned.

	Note:
		- The function initializes an XLSX object, extracts shared strings and number formats, and parses the sheet data.
	*/

	mut xlsx := XLSX.new(xlsxfile)! // Initialize an XLSX object with the provided file path
	shared_strings := xlsx.parse_shared_strings()! // Extract shared strings from the XLSX file

	formats := xlsx.parse_formats()! // Extract number formats from the XLSX file

	// Parse sheet data using the extracted shared strings and formats
	data := xlsx.parse_sheet(shared_strings, formats)!

	return data // Return the parsed data
}
