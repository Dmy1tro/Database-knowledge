
Select 'aaa';

Select * from [Users]
Where [DepartmentId] between 2 and 5
Order By [Birthday] desc;

Select [u].[FirstName], [u].[LastName], [p].[Name] as 'Project' from [UserProjects] as up
Join [Users] as [u] on [up].[UserId] = [u].Id
Join [Projects] as [p] on [up].[ProjectId] = [p].id
Order by [p].[Name]

Select [u].[FirstName], [u].[LastName], Count([p].[Name]) as 'Number of projects' from [UserProjects] as up
Join [Users] as [u] on [up].[UserId] = [u].Id
Join [Projects] as [p] on [up].[ProjectId] = [p].id
Where [u].[Id] = 15
Group By [u].[FirstName], [u].[LastName]
Order by [u].[FirstName], [u].[LastName]
-- Count by field - is it some difference in using different columns ?


-- Using Case When
Select [u].[FirstName], [u].[LastName],
Case [FirstName] 
	When 'Albin' then 'True' 
	Else 'False'
End as 'Case column'
from [Users] as [u]
Order By [Birthday] desc;

-- user 1 - 500
-- user 2 - 400
-- user 3 - 300
-- user 4 - 300
-- user 5 - 300

-- Filtering using TOP
Select top (3) [u].[DepartmentId]
from [Users] as [u]
Order by [DepartmentId];

Select top (3) with ties [u].[DepartmentId]
from [Users] as [u]
Order by [DepartmentId] desc;

Select top (50) percent [u].[DepartmentId]
from [Users] as [u]
Order by [DepartmentId];

--	Transaction
-- https://docs.microsoft.com/en-us/sql/connect/jdbc/understanding-isolation-levels?view=sql-server-ver16
-- https://habr.com/ru/post/469415/

-- Read uncommitted => Has the best performance but worse consistency (Has problem with dirty read)
-- Dirty read => One transaction can see changes from another transaction even if changes are not commited.

-- Read committed => Safes from dirty read (Uncommited changes from another transaction).
-- But has problem with Non-Repeatable Read and Phantom read
-- Non-Repeatable Read => One transaction that in progress see commited changes from another transaction (Update or Delete changes)
-- Phantom read => One transaction that in progress can see commited changes from another transaciton (Insert)

-- Repeatable read => Safes from reading committed Update, Delete changes from another transaction.
-- And maybe safes from reading Inserted objects (depends on DB, but probably not).
-- Protecting from uncommited Update/Delete operations achieved by using lock. Transaction T2 will wait until T1 completes.

-- Snapshot => Full isolated by using versioning.
-- https://www.geeksforgeeks.org/snapshot-isolation-vs-serializable/
-- https://habr.com/ru/post/662566/

-- Serializable => Fully isolated by using locks. Safes from reading phantoms. Has the best consistency but worse performance
-- Act like nothing happening externally of transaction

--SET TRANSACTION ISOLATION LEVEL Read uncommitted
--SET TRANSACTION ISOLATION LEVEL Read committed
--SET TRANSACTION ISOLATION LEVEL Repeatable read
--SET TRANSACTION ISOLATION LEVEL Snapshot
--SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

