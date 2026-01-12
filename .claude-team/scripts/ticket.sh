#!/bin/bash
# CloudSync Ultra - Ticket Helper Script
# Usage: ./ticket.sh [command] [args]

REPO_DIR="/Users/antti/Claude"
TICKETS_DIR="$REPO_DIR/.claude-team/tickets"

case "$1" in
    "list"|"ls")
        echo "📋 Open Issues:"
        cd "$REPO_DIR" && gh issue list --state open
        ;;
    
    "ready")
        echo "✅ Ready for Workers:"
        cd "$REPO_DIR" && gh issue list --label "ready"
        ;;
    
    "progress"|"wip")
        echo "🔄 In Progress:"
        cd "$REPO_DIR" && gh issue list --label "in-progress"
        ;;
    
    "bug")
        echo "🐛 Creating bug report..."
        cd "$REPO_DIR" && gh issue create --template bug_report.yml
        ;;
    
    "feature")
        echo "✨ Creating feature request..."
        cd "$REPO_DIR" && gh issue create --template feature_request.yml
        ;;
    
    "quick")
        # Quick issue creation: ./ticket.sh quick "Title here"
        if [ -z "$2" ]; then
            echo "Usage: ./ticket.sh quick \"Issue title\""
            exit 1
        fi
        cd "$REPO_DIR" && gh issue create --title "$2" --label "triage"
        ;;
    
    "idea")
        # Add idea to inbox: ./ticket.sh idea "Your idea"
        if [ -z "$2" ]; then
            echo "Usage: ./ticket.sh idea \"Your idea here\""
            exit 1
        fi
        echo "- $2" >> "$TICKETS_DIR/INBOX.md"
        echo "💡 Added to inbox: $2"
        ;;
    
    "inbox")
        echo "📥 Inbox Contents:"
        cat "$TICKETS_DIR/INBOX.md"
        ;;
    
    "backup")
        echo "💾 Backing up GitHub issues..."
        cd "$REPO_DIR" && gh issue list --state open --json number,title,labels,body,state > "$TICKETS_DIR/issues_backup.json"
        echo "Saved to $TICKETS_DIR/issues_backup.json"
        ;;
    
    "view")
        # View specific issue: ./ticket.sh view 42
        if [ -z "$2" ]; then
            echo "Usage: ./ticket.sh view [issue_number]"
            exit 1
        fi
        cd "$REPO_DIR" && gh issue view "$2"
        ;;
    
    "help"|"")
        echo "CloudSync Ultra Ticket System"
        echo ""
        echo "Commands:"
        echo "  list, ls     - List all open issues"
        echo "  ready        - Show issues ready for workers"
        echo "  progress     - Show issues in progress"
        echo "  bug          - Create bug report (interactive)"
        echo "  feature      - Create feature request (interactive)"
        echo "  quick \"...\" - Quick issue with just a title"
        echo "  idea \"...\"  - Add idea to local inbox"
        echo "  inbox        - View local inbox"
        echo "  backup       - Backup GitHub issues locally"
        echo "  view [#]     - View specific issue"
        echo ""
        echo "Examples:"
        echo "  ./ticket.sh quick \"Add dark mode support\""
        echo "  ./ticket.sh idea \"Maybe add iCloud sync?\""
        echo "  ./ticket.sh view 42"
        ;;
    
    *)
        echo "Unknown command: $1"
        echo "Run './ticket.sh help' for usage"
        exit 1
        ;;
esac
