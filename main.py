import subprocess
import os
import glob


def build_pdf():
    """Build theGIbook.pdf using latexmk."""
    print("Building theGIbook.pdf...")
    try:
        subprocess.run(
            ["latexmk", "-xelatex", "-bibtex", "theGIbook.tex"],
            check=True
        )
        print("Done: theGIbook.pdf")
    except subprocess.CalledProcessError as e:
        print(f"Error during PDF build: {e}")


def clean_latex():
    """Remove auxiliary LaTeX files."""
    print("Cleaning LaTeX files...")

    # File patterns to remove
    patterns = [
        "*.aux", "*.log", "*.out", "*.toc", "*.lof", "*.lot",
        "*.bbl", "*.blg", "*.brf",
        "*.idx", "*.ilg", "*.ind", "*.synctex.gz",
        "*.mtc*", "*.maf",
        "*.fls", "*.fdb_latexmk", "*.xdv"
    ]

    for pattern in patterns:
        for file in glob.glob(pattern):
            try:
                os.remove(file)
                print(f"Removed: {file}")
            except OSError as e:
                print(f"Failed to remove {file}: {e}")

    print("Clean complete")


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="LaTeX build and clean utility.")
    parser.add_argument(
        "command",
        choices=["build", "clean"],
        help="Command to execute: build or clean"
    )
    args = parser.parse_args()

    if args.command == "build":
        build_pdf()
    elif args.command == "clean":
        clean_latex()
