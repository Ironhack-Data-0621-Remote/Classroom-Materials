# Normalization and functional dependencies

Normalization is performed based on the analysis of functional dependencies that are present in a relation. Given that A and B are two sets of attributes, B functionally depends on A, or in other terms, A determines B, if a given value of A uniquely determines the value of B. The functional dependency of B on A is denoted as `A → B` or represented using a dependency diagram as shown in the figure below. A is called "determinant(s)" and B is called "dependent(s)".

![](https://education-team-2020.s3-eu-west-1.amazonaws.com/data-analytics/3.4-normalization_func_depend_img_1.png)

In the `PrescriptionFilling` relation, since `PrescriptionID` and `MedicineID` are the primary keys of the `PrescriptionFilling` relation, a given value of the primary key uniquely identifies one record of the relation. Hence, we have the following functional dependency:
`PrescriptionID, MedicineID → PharmacyID, PharmacyName, Address, Phone, MedicineName, Description, Quantity, LastPickupDate, and RefillFrequency`.

For any relation, this always is a functional dependency that has the primary key attribute(s) as the determinant(s) and the non-key attribute(s) as the dependents. In addition to the functional dependency with the primary key as the determinant(s), we identify the functional dependencies that have a smaller number of determinants than that in the functional dependency with the primary key as the determinant(s).

Figure below gives a dependency diagram that shows the three functional dependencies in the `PrescriptionFilling` relation.

![](https://education-team-2020.s3-eu-west-1.amazonaws.com/data-analytics/3.4-norm_func_prescription_relation_img_2.png)

The `FD3` is a partial functional dependency. In a partial functional dependency, a non-key attribute depends on some, but not all, of the primary key attributes. In the `FD3`, two non-key attributes are determined by `MedicineID`, which is one of the two primary key attributes.
The `FD2` is a transitive functional dependency. A transitive functional dependency involves no primary key attribute(s). In the `FD2`, none of the `PharmacyID`, `PharmacyName`, `Address`, and `Phone` attributes are a primary key attribute.

The only functional dependency that should be present in a relation is the functional dependency with the primary key as the determinant and all the non-key attributes as the dependents. Additional functional dependencies in the relation, such as partial functional dependency, transitive functional dependency, and any other type of functional dependency, cause data redundancy and data anomalies and should be removed from the relation through normalization.

## Normalization

In general, if no functional dependencies other than the functional dependency with the primary key as the determinant(s) and all the non-key attributes as the dependents can be identified in a relation, the relation is in a normal form without data redundancy and data anomalies. If multiple functional dependencies are identified in a relation, normalization needs to be performed on the relation to remove the functional dependencies other than the one with the primary key as the determinant(s) and all the non-key attributes as the dependents and thus bring the relation to a normal form without data redundancy and data anomalies
Normalization defines the first normal form (`1NF`), the second normal form (`2NF`), the third normal form (`3NF`), the Boyce–Codd normal form (`BCNF`), and so on.
A relation is in `1NF` if each cell of the relation contains only one value. The relation shown below is not in `1NF`.

![](https://education-team-2020.s3-eu-west-1.amazonaws.com/data-analytics/3.4-norm-func-prescription-relation-img-3.png)

**Normalizing to bring `PrescriptionFilling` to `2NF`**

![](https://education-team-2020.s3-eu-west-1.amazonaws.com/data-analytics/3.4-norm_func_prescription_relation_img_4.png)

If `PrescriptionFilling` and the `Medicine` relations in the figure above are not in `3NF`, then perform the normalization to bring the relations to `3NF`. The `Medicine` relation has one functional dependency with the primary key as the determinant and all the non-key attributes as the dependents. The `Medicine` relation is in `2NF`. The `Medicine` relation does not have any transitive functional dependency. Hence, the `Medicine` relation is in `3NF`.
The `PrescriptionFilling` relation has two functional dependencies. The `PrescriptionFilling` relation is in `2NF`. Because the `PrescriptionFilling` relation has a transitive functional dependency, `FD2`, the `PrescriptionFilling` relation is not in `3NF`. We perform the normalization to take out all the attributes in `FD2` and put them in a new relation, `Pharmacy`, while keeping `PharmacyID` in the `PrescriptionFilling` relation as a foreign key.

![](https://education-team-2020.s3-eu-west-1.amazonaws.com/data-analytics/3.4-norm_func_prescription_relation_img_5.png)

Now each relation is in `3NF` and has only one functional dependency with the primary key as the determinant and all the non-key attributes as the dependents. A relation is in `BCNF` if the relation is in `3NF` and does not have any functional dependency whose determinant(s) is not the primary key.
{"mode":"full","isActive":false}