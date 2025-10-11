# GitHub Fine-Grained Token Setup Guide

This guide explains how to create a repository-scoped GitHub token for automated deployments.

## Why Fine-Grained Tokens?

Fine-grained tokens are more secure than classic personal access tokens because:
- ✅ **Repository-specific** - Only works for one repository
- ✅ **Limited permissions** - Only has read access to code
- ✅ **Expiration** - Automatically expires (security best practice)
- ✅ **Revocable** - Can be revoked without affecting other tokens
- ✅ **Stored on server** - Not in GitHub Secrets (one less place to leak)

## Step-by-Step Instructions

### Step 1: Navigate to Token Settings

1. Log into GitHub
2. Click your **profile picture** (top right)
3. Click **Settings**
4. Scroll down to **Developer settings** (bottom of left sidebar)
5. Click **Personal access tokens**
6. Click **Fine-grained tokens**

### Step 2: Generate New Token

Click the **"Generate new token"** button.

### Step 3: Configure Token Details

#### Basic Information

| Field | Value | Notes |
|-------|-------|-------|
| **Token name** | `cyberpoker-server-deploy` | Descriptive name for identification |
| **Description** | `Automated deployment for CyberPoker server` | Optional but helpful |
| **Expiration** | `90 days` (recommended) | Can choose 30, 60, 90, or custom |

**Note:** You'll need to regenerate the token when it expires. GitHub will email you reminders.

#### Repository Access

1. Select **"Only select repositories"**
2. Click the dropdown
3. Search for and select: `cyberpoker-server`

**Important:** Do NOT select "All repositories" - this is a security risk!

#### Permissions

Under **Repository permissions**, set:

| Permission | Access Level | Why? |
|------------|-------------|------|
| **Contents** | ✅ **Read-only** | Required to clone/pull repository code |
| **Metadata** | ✅ **Read-only** | Automatically selected (required) |

**Important:** 
- Do NOT grant write access
- Do NOT grant access to other permissions
- Less is more for security!

### Step 4: Generate Token

1. Scroll to the bottom
2. Click **"Generate token"**
3. **IMMEDIATELY COPY THE TOKEN** 
   - It starts with `github_pat_`
   - You'll only see it once!
   - If you lose it, you must generate a new one

Example token format: `github_pat_11A...XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX`

### Step 5: Store Token on Server

Now SSH into your Linux server and store the token securely:

```bash
# SSH into your server
ssh your-user@your-server.com

# Create the token file
nano ~/.github_token

# Paste your token and save:
# - Paste the token (Ctrl+Shift+V or right-click)
# - Press Ctrl+X to exit
# - Press Y to confirm save
# - Press Enter to confirm filename
```

**Or use echo command:**

```bash
# Replace YOUR_TOKEN_HERE with your actual token
echo "github_pat_11A...XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" > ~/.github_token
```

### Step 6: Secure the Token File

```bash
# Set restrictive permissions (owner read/write only)
chmod 600 ~/.github_token

# Verify permissions
ls -la ~/.github_token
```

**Expected output:**
```
-rw------- 1 ubuntu ubuntu 93 Oct 11 10:00 /home/ubuntu/.github_token
```

The `-rw-------` means:
- Owner can read and write
- Group cannot access
- Others cannot access

### Step 7: Verify Token Works (Optional)

Test the token can access your repository:

```bash
# Load token
TOKEN=$(cat ~/.github_token)

# Test API access
curl -H "Authorization: token $TOKEN" \
     https://api.github.com/repos/YOUR-USERNAME/cyberpoker-server

# Should return JSON with repository info
```

If you get a 200 response with repo details, the token works!

## Token Management

### Check Token Expiration

1. Go to **Settings** → **Developer settings** → **Personal access tokens** → **Fine-grained tokens**
2. Find your token in the list
3. Check the **Expires** column

GitHub will email you:
- 7 days before expiration
- 1 day before expiration
- On expiration day

### Renew Expired Token

When your token expires:

1. **Generate new token** (follow Steps 1-4 above with same settings)
2. **Update server:**
   ```bash
   ssh your-user@your-server.com
   echo "github_pat_NEW_TOKEN_HERE" > ~/.github_token
   chmod 600 ~/.github_token
   ```
3. **Test deployment** to verify it works

### Revoke Token

If compromised or no longer needed:

1. Go to **Settings** → **Developer settings** → **Personal access tokens** → **Fine-grained tokens**
2. Find your token
3. Click **Revoke**
4. Confirm revocation

**Then generate a new one if still needed.**

## Security Best Practices

### ✅ DO

- Use fine-grained tokens (not classic PATs)
- Limit to specific repository only
- Use read-only permissions when possible
- Set expiration dates (90 days recommended)
- Store in secure location with 600 permissions
- Regenerate if compromised
- Delete token file when decommissioning server

### ❌ DON'T

- Grant "All repositories" access
- Give write permissions unless absolutely needed
- Use classic personal access tokens
- Set "No expiration"
- Share tokens between projects
- Commit tokens to git repositories
- Store in world-readable files
- Use the same token on multiple servers

## Troubleshooting

### "Bad credentials" Error

**Cause:** Token is invalid, expired, or has wrong permissions

**Fix:**
1. Check token hasn't expired
2. Verify token is correctly saved: `cat ~/.github_token`
3. Ensure no extra spaces or newlines in file
4. Generate new token if needed

### "Not Found" Error

**Cause:** Token doesn't have access to the repository

**Fix:**
1. Verify token has access to `cyberpoker-server` repository
2. Check repository name is spelled correctly
3. Ensure repository access wasn't revoked

### Deployment Clones but Fails

**Cause:** Token works but might have wrong permissions or repo issues

**Fix:**
1. Check deployment logs in GitHub Actions
2. Verify Git LFS is installed: `git lfs version`
3. Check Docker is installed: `docker --version`

### Token File Permissions Error

**Cause:** File has wrong permissions (too open)

**Fix:**
```bash
chmod 600 ~/.github_token
ls -la ~/.github_token  # Verify shows -rw-------
```

## FAQ

**Q: Why not use GitHub Secrets?**
A: Storing the token on the server reduces the attack surface. If someone compromises your GitHub Actions secrets, they don't automatically get your deployment token.

**Q: What if I have multiple servers?**
A: Generate a separate token for each server. This way, if one server is compromised, you can revoke just that token.

**Q: Can I use one token for multiple repositories?**
A: You can, but it's not recommended. Use separate tokens for better security and easier revocation.

**Q: What happens when the token expires?**
A: Deployments will fail with authentication errors. Just generate a new token and update the file on your server.

**Q: Is 90 days too short?**
A: It's a security best practice. Regular rotation reduces risk. GitHub will remind you before expiration.

**Q: Can I see the token after I create it?**
A: No. If you lose it, you must generate a new one. That's why we store it immediately in the file.

---

**Last Updated:** 2025-10-11
