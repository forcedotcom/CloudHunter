<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Award_Points</fullName>
        <description>Set the points awarded on the Achievement to equal the current point value on the mission completed by the player.</description>
        <field>Points_Awarded__c</field>
        <formula>Mission__r.Current_Point_Value__c</formula>
        <name>Award Points</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Points Awarded</fullName>
        <actions>
            <name>Award_Points</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Mission__c.Current_Point_Value__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
