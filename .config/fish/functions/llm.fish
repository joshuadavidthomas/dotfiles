function llm --wraps=llm
    command llm $argv | glow -
end
