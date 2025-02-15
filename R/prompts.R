#' Construct LLM prompt
#'
#' Construct a LLM prompt based on user input
#'
#' @param blog_link URL of source material
#' @param platforms Social media platform to create prompts for
#' @param n Number of prompts to create for each platform
#' @param emojis Use emojis in post?
#' @param tone Desired tone of the post
#' @param hashtags Hashtags to include in the post
#' @importFrom glue glue
get_prompt <- function(blog_link, platforms, n, emojis, tone, hashtags) {
  # retrieve post contents from GitHub
  post_contents <- fetch_github_markdown(blog_link)

  # paste list of platforms together
  platform_string <- paste(platforms, collapse = ", ")

  # set up string about emojis
  emoji_string <- ifelse(emojis, "Use", "Do not use")

  # set up hashtags
  hashtag_string <- ifelse(
    is.null(hashtags),
    "",
    glue::glue(
      "Where relevant to the platform, use the following hashtags: {hashtags}. Don't add any others."
    )
  )

  # combine components
  glue::glue(
    "Create me {n} posts for each of these social media platforms: {platform_string}
    to promote the below blog post. {emoji_string} emojis.  Use a {tone} tone. \n{post_contents}.
    {hashtag_string}"
  )
}

#' Fetch markdown file from GitHub
#'
#' Fetches a markdown file from GitHub, converting it to the raw content URL if it's not already one.
#'
#' @param url URL of file
#' @importFrom httr GET content status_code
fetch_github_markdown <- function(url) {
  # Convert to raw content URL if it's a GitHub repository URL
  if (grepl("github.com", url) && !grepl("raw.githubusercontent.com", url)) {
    url <- sub("github.com", "raw.githubusercontent.com", url)
    url <- sub("/blob/", "/", url)
  }

  # Fetch content
  response <- GET(url)

  # Check for successful retrieval
  if (status_code(response) == 200) {
    content <- content(response, as = "text", encoding = "UTF-8")
    return(content)
  } else {
    stop("Failed to retrieve the file. Check the URL and try again.")
  }
}

#' Call the LLM API with the prompt
#'
#' @param prompt Prompt to use as input
#' @importFrom ellmer chat_gemini
call_llm_api <- function(prompt) {
  chat <- chat_gemini(echo = "none")
  out <- chat$chat(prompt)
}
