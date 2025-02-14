library(httr)
library(glue)
library(ellmer)

get_prompt <- function(blog_link, platforms, n, emojis, tone, hashtags){
  
  post_contents <- fetch_github_markdown(blog_link)
  platform_string <- paste(platforms, collapse = ", ")
  emoji_string <- ifelse(emojis, "Use", "Do not use")
  hashtag_string <- ifelse(is.null(hashtags), "", glue::glue("Where relevant to the platfotm, use the following hashtags: {hashtags}"))
  
  glue::glue(
    "Create me {n} posts for each of these social media platforms: {platform_string} to
    promote the below blog post. {emoji_string} emojis.  Use a {tone} tone. \n{post_contents}. {hashtag_string}"
  )
}

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

call_llm_api <- function(prompt){
  chat <- chat_gemini(echo = "none")
  out <- chat$chat(prompt)
}
