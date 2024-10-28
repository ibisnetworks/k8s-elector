#!/bin/bash

# exit on first error
set -e

APPNAME="k8s-elector"

Usage() {
  echo "Usage: ${0} [-a AUTHOR] [-b BRANCH]"
  echo
  echo "Options:"
  echo "-a AUTHOR         The Git repository commit author"
  echo "-b BRANCH         The Git repository branch name"
  echo "-n NAMESPACE      The K8S namespace"
  echo "-h                Show this message and exit"
}

UserToNamespaceMap() {
  case ${1} in
    "GrantChina"         ) echo "grant";;
    "jeffreyt"           ) echo "jeff";;
    "mmadsen"|"madsenwattiq") echo "mark";;
    "rbk1234"|"robkiessling") echo "robbie";;
    "rapkat10"           ) echo "rapkat";;
    *) echo "Unknown user ${1}" 1>&2; exit 1;;
  esac
}

EmailToNamespaceMap() {
  case ${1} in
    "grant@ibisnetworks.com" ) echo "grant";;
    "jeff@ibisnetworks.com"  ) echo "jeff";;
    "mark@ibisnetworks.com"  ) echo "mark";;
    "robert@ibisnetworks.com") echo "robbie";;
    "rapkat.amin@wattiq.io" ) echo "rapkat";;
    *) echo "Unknown email ${1}" 1>&2; exit 1;;
  esac
}

while getopts a:b:hn: option
do
  case "${option}" in
    a) AUTHOR=${OPTARG};;
    b) BRANCH=${OPTARG};;
    n) NAMESPACE=${OPTARG};;
    h) Usage; exit 0;;
    *) Usage; exit 1;;
  esac
done

# If branch is "development", that's all we need to know
if [ "${BRANCH}" = "development" ] ; then
  echo "staging/${APPNAME}"
  exit 0
fi

# If branch is "master", that's all we need to know
if [ "${BRANCH}" = "master" ] ; then
  echo "production/${APPNAME}"
  exit 0
fi

if [ "${NAMESPACE}" = "staging" ]; then 
  echo "staging/${APPNAME}"
  exit 0
fi

if [ "${NAMESPACE}" = "production" ]; then
  echo "production/${APPNAME}"
  exit 0
fi


# If no namespace was passed in, try various options to infer it
if [ -z "${NAMESPACE}" ] ; then
  # If author was passed in, map git author to namespace
  if [ -n "${AUTHOR}" ] ; then
    NAMESPACE=$(UserToNamespaceMap "${AUTHOR}")
  fi

  # If still no namespace, try to use the namespace of the current context
  if [ -z "${NAMESPACE}" ] ; then
    CURRENT_CONTEXT=$(kubectl config view -o=jsonpath='{.current-context}')
    JSONPATH="{.contexts[?(@.name==\"${CURRENT_CONTEXT}\")].context.namespace}"
    NAMESPACE=$(kubectl config view -o=jsonpath="${JSONPATH}")
  fi

  # If still no namespace, try to map git user email to namespace
  if [ -z "${NAMESPACE}" ] ; then
    user_email=$(git config --get user.email)
    NAMESPACE=$(EmailToNamespaceMap "${user_email}")
  fi
fi

# If there's still no namespace, give up
if [ -z "${NAMESPACE}" ] ; then
  echo "Unable to determine namespace" 1>&2
  Usage
  exit 1
fi




REPONAME="${NAMESPACE}/${APPNAME}"
echo "${REPONAME}"
