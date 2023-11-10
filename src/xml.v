module read_xlsx_v

struct Parser {
	source string

	mut:
		index int
}

struct XMLParser {
	Parser

	pub mut:
		parent_indexes []int = [-1]
		level int
		tags []&Tag
}

struct Tag {
	pub:
		name string
		attributes map[string]string
		is_close bool
		is_self_close bool

	pub mut:
		parent_index int = -1
		level int
		text string
		children []&Tag
		parent &Tag = unsafe { nil }
}

struct TagParser {
  	Parser
}

fn is_space(r rune) bool {
	/*
	is_space checks if the given rune represents a space character.

	Parameters:
		- r: A rune to be checked.

	Returns:
		- A boolean indicating whether the rune is a space character.
	*/
	return u8(r).is_space() // Check if the ASCII value of the rune represents a space character
}

fn (mut p Parser) skip_whitespace() {
	/*
	skip_whitespace advances the parser's position past consecutive whitespace characters.

	Parameters:
		- p: A mutable Parser object.

	Note:
		- This method uses the match_char method of the Parser to check if the current character is a whitespace character.
		- It continues advancing the parser's position while encountering consecutive whitespace characters.
	*/
	for p.match_char(is_space, true) {} // Iterate through consecutive whitespace characters using match_char
}

fn (mut p Parser) parse_until(predict fn(rune) bool) string {
	/*
	parse_until parses the input string until a specified condition is met and returns the parsed substring.

	Parameters:
		- p: A mutable Parser object.
		- predict: A function that takes a rune and returns a boolean indicating whether the parsing should continue.

	Returns:
		- A string representing the substring parsed until the specified condition is met.

	Note:
		- This method advances the parser's position using the match_char method while the specified condition holds true.
		- The substring between the starting index and the index where the condition is met is returned.
	*/

	start := p.index // Record the starting index of parsing
	for p.match_char(predict, true) {} // Continue parsing until the specified condition is no longer met

	return p.source[start .. p.index] // Return the parsed substring between the starting index and the current index
}

fn (mut p Parser) is_char(ch rune, advance bool) bool {
	/*
	is_char checks if the current character in the parsed string matches a specified character.

	Parameters:
		- p: A mutable Parser object.
		- ch: The rune to be checked for a match.
		- advance: A boolean indicating whether to advance the parser's position if there is a match.

	Returns:
		- A boolean indicating whether the current character matches the specified rune.

	Note:
		- This method uses the match_char method of the Parser with a function that checks if the current rune is equal to the specified character.
		- The parser's position is advanced if the 'advance' parameter is set to true.
	*/

	// Use match_char with a function to check if the current rune is equal to the specified character
	return p.match_char(fn [ch] (r rune) bool { return ch == r }, advance)
}

fn (mut p Parser) match_char(predict fn(rune) bool, advance bool) bool {
	/*
	match_char checks if the current character in the parsed string satisfies a specified condition.

	Parameters:
		- p: A mutable Parser object.
		- predict: A function that takes a rune and returns a boolean indicating whether the match is successful.
		- advance: A boolean indicating whether to advance the parser's position if there is a match.

	Returns:
		- A boolean indicating whether the current character satisfies the specified condition.

	Note:
		- This method uses the peek_char method of the Parser to check the current character without advancing the position.
		- If the character satisfies the condition, the parser's position is advanced if the 'advance' parameter is set to true.
	*/

	// Use peek_char to check the current character without advancing the position
	if ch, index := p.peek_char() {
		// Check if the current character satisfies the specified condition
		if predict(ch) {
			// Advance the parser's position if required
			if advance {
				p.index = index
			}
			return true
		}
		return false
	} else {
		return false
	}
}

fn (mut p Parser) next_char() ?rune {
	/*
	next_char retrieves the next character in the parsed string without advancing the parser's position.

	Parameters:
		- p: A mutable Parser object.

	Returns:
		- A rune representing the next character in the parsed string, or none if the end of the string is reached.

	Note:
		- This method uses the peek_char method of the Parser to retrieve the next character without advancing the position.
		- If a character is found, the parser's position is not modified.
		- If the end of the parsed string is reached, the method returns the none value.
	*/

	// Use peek_char to retrieve the next character without advancing the position
	if ch, index := p.peek_char() {
		p.index = index

		return ch
	} else {
		return none
	}
}

fn (mut p Parser) peek_char() ?(rune, int) {
	/*
	peek_char looks at the current character in the parsed string without advancing the parser's position.

	Parameters:
		- p: A mutable Parser object.

	Returns:
		- A tuple containing the current character as a rune and the index where the character ends.
		- If the end of the string is reached, the method returns none.

	Note:
		- This method checks if the parser's position is at the end of the parsed string.
		- It calculates the length of the current UTF-8 character and returns the character and the end index.
	*/

	// Check if the parser's position is at the end of the parsed string
	if p.index >= p.source.len {
		return none
	}

	start := p.index // Record the starting index of the current character
	char_len := utf8_char_len(unsafe { p.source.str[start] }) // Calculate the length of the current UTF-8 character

	// Calculate the end index of the current character
	end := if p.source.len - 1 >= p.index + char_len { p.index + char_len } else { p.source.len }

	r := unsafe { p.source[start .. end] } // Create a substring representing the current character
	ch := r.utf32_code() // Convert the substring to a rune (UTF-32 code)

	return ch, end // Return the rune and the end index
}

fn XMLParser.new(source string) []&Tag {
	/*
	XMLParser.new creates a new XMLParser object and parses the provided XML source.

	Parameters:
		- source: A string containing the XML source to be parsed.

	Returns:
		- A slice of references to Tag objects representing the parsed XML structure.
	*/

	// Create a new XMLParser object
	mut parser := XMLParser {
		source: source,
	}

	parser.parse() // Parse the XML content

	return parser.tags // Return a slice of references to Tag objects
}

fn (mut p XMLParser) parse() {
	/*
	parse organizes the parsed tags into a hierarchical structure based on parent-child relationships.

	Parameters:
		- p: A mutable XMLParser object.

	Note:
		- This method assumes that parse_tag has been previously called to populate the p.tags slice with parsed tags.
		- It iterates through the tags and assigns parent-child relationships based on the parent_index attribute.
	*/
	// Iterate through the parsed tags and organize them into a hierarchical structure
	for p.parse_tag() {}

	// Iterate through the tags to establish parent-child relationships
	for i, tag in p.tags {
		if tag.parent_index > -1 {
			mut parent := p.tags[tag.parent_index] // Retrieve the parent tag

			parent.children << tag // Add the current tag as a child of the parent
			p.tags[i].parent = parent // Set the parent reference for the current tag
		}
	}
}

fn (mut p XMLParser) parse_tag() bool {
	/*
	parse_tag parses an XML tag from the current position in the parser's source.

	Parameters:
		- p: A mutable XMLParser object.

	Returns:
		- A boolean indicating whether a tag was successfully parsed.

	Note:
		- This method updates the parser's tags slice with Tag objects representing the parsed tags.
		- It handles opening, closing, and self-closing tags, as well as text content within tags.
	*/

	p.skip_whitespace() // Skip leading whitespaces
	start := p.index // Record the starting index of the tag

	// Get the next character
	if ch := p.next_char() {
		match ch {
			`<` {
				// For opening, closing, or self-closing tags, advance until '>' is found
				for p.match_char(fn (r rune) bool { return r != `>` }, true) {}

				p.next_char() // Consume '>'

				tag_source := p.source[start .. p.index] // Extract the source code of the tag
				mut tag := Tag.new(tag_source) // Create a new Tag object based on the tag source

				if tag.is_close {
					// If it's a closing tag, update the parser's state accordingly
					p.level -= 1
					p.parent_indexes.delete_last()

				} else if tag.is_self_close {
					// If it's a self-closing tag, set the level and parent_index and add it to the tags slice
					tag.level = p.level
					tag.parent_index = p.parent_indexes.last()
					p.tags << tag

				} else {
					// If it's an opening tag, set the level and parent_index, add it to the tags slice, and update the parser's state
					tag.level = p.level
					tag.parent_index = p.parent_indexes.last()
					p.tags << tag
					p.level += 1
					p.parent_indexes << p.tags.len - 1
				}
			}
			else {

				for p.match_char(fn (r rune) bool { return r != `<` }, true) {} // For text content within tags, advance until '<' is found

				text := p.source[start .. p.index].trim_space() // Extract the text content

				// Create a new Tag object for the text content
				tag := &Tag {
					name: '#text',
					text: text,
					parent_index: p.parent_indexes.last(),
					level: p.level,
				}

				// Add the text content tag to the tags slice
				p.tags << tag
			}
		}
		return true
	} else {
		return false
	}
}

fn (tag &Tag) text() string {
	/*
	text retrieves the text content of the tag.

	Parameters:
		- tag: A reference to a Tag object.

	Returns:
		- A string representing the text content of the tag.

	Note:
		- If the tag's name is '#text', the method returns the text property.
		- Otherwise, if the tag has children, it recursively concatenates the text content of its children.
	*/

	// Check if the tag's name is '#text'
	if tag.name == '#text' {
		return tag.text
	} else {
		return tag.children.map(it.text()).join('') // If the tag has children, recursively concatenate their text content
	}
}

fn Tag.new(source string) &Tag {
	/*
	Tag.new creates a new Tag object by parsing the provided tag source.

	Parameters:
		- source: A string containing the source code of the tag.

	Returns:
		- A reference to a Tag object representing the parsed tag.
	*/
	mut parser := TagParser { source: source } // Create a new TagParser object

	return parser.parse() // Parse the tag content
}

fn (mut p TagParser) parse_is_close() bool {
	/*
	parse_is_close checks if the current character in the parser's source is the closing character '/'.

	Parameters:
		- p: A mutable TagParser object.

	Returns:
		- A boolean indicating whether the current character is the closing character '/'.
	*/
	return p.is_char(`/`, true) // Use the is_char method to check if the current character is '/'
}

fn (mut p TagParser) parse_name() string {
	/*
	parse_name extracts the name of an XML tag from the parser's source.

	Parameters:
		- p: A mutable TagParser object.

	Returns:
		- A string representing the name of the XML tag.
	*/

	// Use parse_until to extract the name of the XML tag
	name := p.parse_until(fn (r rune) bool { return !is_space(r) && r != `/` && r != `>` })

	return name // Return the extracted name
}

fn (mut p TagParser) parse_attributes() map[string]string {
	/*
	parse_attributes parses attributes of an XML tag from the parser's source.

	Parameters:
		- p: A mutable TagParser object.

	Returns:
		- A map of attribute key-value pairs.
	*/

	mut attributes := map[string]string{} // Initialize an empty map to store attribute key-value pairs

	// Iterate through the source to extract attribute key-value pairs
	for p.match_char(fn (r rune) bool { return r != `>` }, false) {

		p.skip_whitespace() // Skip leading whitespaces

		// Check if the current character indicates the end of attributes
		if p.match_char(fn (r rune) bool { return r == `>` || r == `/` || r == `?` }, false) {
			break
		}

		key := p.parse_until(fn (r rune) bool { return r != `=` }) // Extract the attribute key
		p.next_char() // Consume the equal sign

		p.skip_whitespace() // Skip whitespaces after the equal sign
		p.next_char() // Consume the left double quote

		value := p.parse_until(fn (r rune) bool { return r != `"` }) // Extract the attribute value
		p.next_char() // Consume the right double quote

		attributes[key] = value // Add the attribute key-value pair to the map
	}

	return attributes // Return the map of attribute key-value pairs
}

fn (mut p TagParser) parse_is_self_close() bool {
	/*
	parse_is_self_close checks if the current character in the parser's source is '/' or '?'.

	Parameters:
		- p: A mutable TagParser object.

	Returns:
		- A boolean indicating whether the current character is '/' or '?'.
	*/

	// Use the is_char method to check if the current character is '/' or '?'
	return p.is_char(`/`, true) || p.is_char(`?`, true)
}

fn (mut p TagParser) parse() &Tag {
	/*
	parse parses an XML tag from the parser's source.

	Parameters:
		- p: A mutable TagParser object.

	Returns:
		- A reference to a Tag object representing the parsed XML tag.
	*/

	p.next_char() // Consume the opening '<' character
	is_close := p.parse_is_close() // Check if the tag is a closing tag

	name := p.parse_name() // Parse the tag name
	attributes := p.parse_attributes() // Parse the tag attributes

	is_self_close := p.parse_is_self_close() // Check if the tag is self-closing
	p.next_char() // Consume the closing '>' character

	// Create and return a reference to a Tag object with the parsed information
	return &Tag{
		name:          name,
		attributes:    attributes,
		is_close:      is_close,
		is_self_close: is_self_close,
	}
}
