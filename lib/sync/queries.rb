module Sync
  module GithubQueries
    PROJECT_QUERY = <<~GRAPHQL
      query GetFullProjectV2Details($organization: String!, $number: Int!) {
        organization(login: $organization) {
          projectV2(number: $number) {
            id
            title
            number
            public
            createdAt
            updatedAt

            items(first: 100) {
              totalCount
              edges {
                node {
                  content {
                    ... on Issue {
                      title
                      url
                      state
                      number
                      body
                      closedAt
                      assignees(first: 10) {
                        nodes {
                          name
                          login
                        }
                      }
                      author {
                        login
                        ... on User {
                          name
                          login
                        }
                        ... on Organization {
                          name
                          login
                        }
                        ... on EnterpriseUserAccount {
                          name
                          login
                        }
                      }
                      milestone {
                        title
                      }
                      labels(first: 10) {
                        nodes {
                          name
                        }
                      }
                    }
                    ... on DraftIssue {
                      title
                      body
                      creator {
                        login
                        ... on User {
                          name
                          login
                        }
                        ... on Organization {
                          name
                          login
                        }
                        ... on EnterpriseUserAccount {
                          name
                          login
                        }
                      }
                      assignees(first: 10) {
                        nodes {
                          name
                          login
                        }
                      }
                    }
                    ... on PullRequest {
                      title
                      url
                      number
                      body
                      state
                      closedAt
                      assignees(first: 10) {
                        nodes {
                          name
                          login
                        }
                      }
                      author {
                        ... on User {
                          name
                          login
                        }
                        ... on Organization {
                          name
                          login
                        }
                        ... on EnterpriseUserAccount {
                          name
                          login
                        }
                      }
                    }
                  }
                  createdAt
                  updatedAt
                  isArchived
                }
              }
            }

            fields(first: 100) {
              nodes {
                ... on ProjectV2FieldConfiguration {
                  __typename
                  ... on ProjectV2SingleSelectField {
                    id
                    name
                    dataType
                    options {
                      id
                      name
                    }
                  }
                  ... on ProjectV2IterationField {
                    id
                    name
                    dataType
                  }
                }
              }
            }

            views(first: 100) {
              nodes {
                id
                name
                number
              }
            }
          }
        }
      }
    GRAPHQL
  end
end
