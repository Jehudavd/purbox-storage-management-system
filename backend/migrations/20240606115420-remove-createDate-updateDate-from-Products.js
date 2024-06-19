'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.removeColumn('Products', 'createDate');
    await queryInterface.removeColumn('Products', 'updateDate');
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.addColumn('Products', 'createDate', {
      type: Sequelize.DATE,
      allowNull: true,
    });
    await queryInterface.addColumn('Products', 'updateDate', {
      type: Sequelize.DATE,
      allowNull: true,
    });
  }
};
